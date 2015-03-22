require 'bcrypt'
require 'models/Password_Reset'
require 'models/Life'
require 'models/Failed_Log_In_Attempt'

class Member 

  include Go_Mon::Model

  # ==== CONSTANTS ====
  
  Wrong_Password              = Class.new( StandardError )
  Invalid_Security_Level      = Class.new( StandardError )

  SECURITY_LEVELS        = %w{ NO_ACCESS STRANGER  MEMBER  EDITOR   ADMIN }
  SECURITY_LEVELS.each do |k|
    const_set k, k
  end
  
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/

  # ==== Associations  ====
    
  has_many :lifes, :Life, :owner_id
  
  # ==== Fields  =====
    
  enable_timestamps
  
  make :security_level,  [:in_array, SECURITY_LEVELS]
  make :hashed_password, :not_empty
  make :salt,            :not_empty 
  make :email, 
    :string,
    [:stripped, /[^a-z0-9\.\-\_\+\@]/i ],
    [:match, /\A[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]\Z/ ],
    [:min, 6],
    [:equal, lambda { raw_data.email } ],
    [:error_msg, 'Email has invalid characters.']
  
  make_psuedo :category, :anything
  make_psuedo :add_username, :anything
    # # Delete invalid characters and 
    # # reduce any suspicious characters. 
    # # '..*' becomes '.'
    # [:stripped, /[^a-z0-9_-]{1,}/i, lambda { |s|
    #     if ['.'].include?( s[0,1] )
    #       s[0,1]
    #     else
    #       ''
    #     end
    #   }], 
    #  [:min, 2, 'Username is too small. It must be at least 2 characters long.'],
    #  [:max, 20, 'Username is too large. The maximum limit is: 20 characters.'],
    #  [:not_match, /[^a-zA-Z0-9\.\_\-]/, 'Username can only contain the follow characters: A-Z a-z 0-9 . _ -']
  
  make_psuedo :update_username, :not_empty
  make_psuedo :confirm_password, :not_empty
  make_psuedo :password, 
      :not_empty,
      [:min, 5],
      [:equal, lambda { self.raw_data.confirm_password }, 'Password and password confirmation do not match.' ],
      # [:match, /[0-9]/, 'Password must have at least one number' ],
      [:if_no_errors, lambda {
          new_data.salt = begin
                            # Salt and encrypt values.
                            chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                            (1..10).inject('') { |new_pass, i|  
                              new_pass += chars[rand(chars.size-1)] 
                              new_pass
                            }
                          end

          new_data.hashed_password = BCrypt::Password.create( cleanest(:password) + new_data.salt ).to_s
      }]
      
  # ==== Class Methods =====================================================    

  class << self

    def valid_security_level?(perm_level)
      return true if SECURITY_LEVELS.include?(perm_level)
      case perm_level
      when BSON::ObjectId, Member, String, Symbol
        true
      else
        false
      end
    end

    
    # Based on Sinatra-authentication (on github).
    # 
    # Parameters:
    #   raw_vals - Hash with at least 2 keys: :username, :password
    # 
    # Raises: 
    #   Member::Wrong_Password
    #
    def authenticate( raw_vals )

      username   = (raw_vals[:username] || raw_vals['username']).to_s.strip
      password   = (raw_vals[:password] || raw_vals['password']).to_s.strip
      ip_addr    = (raw_vals[:ip_address] || raw_vals['ip_address']).to_s.strip
      user_agent = (raw_vals[:user_agent] || raw_vals['user_agent']).to_s.strip
      
      ip_addr    = nil if ip_addr.empty?
      user_agent = nil if user_agent.empty?

      if username.empty? || password.empty?
        raise Wrong_Password, "#{raw_vals.inspect}"
      end
      mem = Life.find.username( username ).grab(:owner).go_first!

      # Check for Password_Reset
      raise Password_Reset::In_Reset, mem.inspect if mem.password_in_reset?

      # Check for too many failed attempts.
      # Raise Account::Reset if necessary.
      fail_count = Failed_Log_In_Attempt.for_today(mem).count
      if fail_count > 2
        mem.reset_password
        raise Password_Reset::In_Reset, mem.inspect
      end
      
      # See if password matches with correct password.
      correct_password = BCrypt::Password.new(mem.data.hashed_password) === (password + mem.data.salt)
      return mem if correct_password

      # Update failed count.
      new_count  = fail_count + 1
      
      # Insert failed password.
      Failed_Log_In_Attempt.create(
        nil,
        :owner_id   => mem.data._id, 
        :ip_address => ip_addr,
        :user_agent => user_agent 
      )

      raise Wrong_Password, "Password is invalid for: #{username.inspect}"
    end 
  
  end # === self

  # ==== Getters ===========

  # ==== Authorizations ====

  class << self
    
    def create editor, raw_raw_data # CREATE
      super.instance_eval do
        new_data.security_level = Member::MEMBER
        ask_for :email
        demand  :password
        generate_id
        save_create
      end
    end
    
    def update id, editor, new_raw_data # UPDATE

      super.instance_eval do
        ask_for :add_username 

        if manipulator == self
          ask_for :password  
        end

        if manipulator.has_power_of? ADMIN
          ask_for :security_level
        end
        un_id = nil
        
        save_update 
      end
    end

    def delete id, editor
      obj = begin
              by_id(id)
            rescue Member::Not_Found
              nil
            end
      if obj
        super(id, editor)
        Trashed_Members.create(editor, obj.data.as_hash)
      end
      obj
    end
    
  end # === self

  def before_create
    return false if not valid?

    set_default :_id
    
    begin
      life = Life.create( self, 
                         :username   => cleanest(:add_username) || raw_data.add_username,  
                         :owner_id   => (data && data._id) || cleanest(:_id),
                         :category   => cleanest(:category) || raw_data.category
                        )

    rescue Life::Invalid => err
      errors.concat $!.doc.errors
    end
  end

  def before_update
    if raw_data.add_username
      before_create
    end
  end

  def allow_to? action, editor # NEW, CREATE
    case action
      when :create
        editor ? false : true
      when :read
        read
      when :update
        return false if !editor
        return true if self.data._id == editor.data._id
        return true if editor.has_power_of?(:ADMIN)
        false
      when :delete
        allow_to? :update, editor
    end
  end


  # ==== UPDATORS ======================================================
  
  attr_accessor :password_reset
  def password_reset
    @password_reset ||= begin
                          Password_Reset.by_id(self.data._id)
                        rescue Password_Reset::Not_Found
                          nil
                        end
  end

  def password_in_reset?
    !!password_reset
  end

  def change_password_through_reset opts
    result = password_reset.change_password opts
    @password_reset = nil
    result
  end
  
  def reset_password
    self.password_reset = Password_Reset.create(self)
  end


  # ==== ACCESSORS =====================================================

  def lang
    'en-us'
  end

  # 
  # By using a custom implementation, we cane make sure
  # sensitive information is not shown.
  #
  def inspect
    if new?
      "#<#{self.class}:#{self.object_id} _id=[NEW]>"
    else
      "#<#{self.class}:#{self.object_id} _id=#{self.data._id}>"
    end
  end

  def has_power_of?(raw_level)

    return true if raw_level == self
    
    if raw_level.is_a?(String) || raw_level.is_a?(BSON::ObjectId)
      return true if lifes.usernames.include?(raw_level)
      return true if data._id === raw_level
      return true if lifes._ids.include?(raw_level)
    end

    if !self.class.valid_security_level?(raw_level)
      raise Invalid_Security_Level, raw_level.inspect
    end
    
    target_level = raw_level.to_s
    return false if target_level == NO_ACCESS
    return true if target_level == STRANGER
    return false if new? 

    member_index = SECURITY_LEVELS.index(self.data.security_level)
    target_index = SECURITY_LEVELS.index(target_level)
    return false if not target_index
    return member_index >= target_index

  end # === def security_clearance?

  # 
  # Returns the time passed to it to the Member's local time
  # as a String, formatted i18n to their Country preference.
  # Default value of :utc is Time.now.utc
  # 
  def local_time_as_string( utc = nil )
    utc ||= Time.now.utc
    @tz_proxy ||= TZInfo::Timezone.get(self.timezone)
    @tz_proxy.utc_to_local( utc ).strftime('%a, %b %d, %Y @ %I:%M %p')
  end 

  #   => Grab all follows (where :target_class => 'Club')
  #      for member, with only fields :follower_id, :club_id
  #      and then convert each :club_id to Club docs.
  # 
  # Returns:
  #   { 
  #     :follower_id => [ club, club ],
  #     :follower_id => [ club, club, club ]
  #   }
  #   
  def club_follower_menu
    find.
      lifes.
      follows.clubs.
      grab(Club).
      group_by(:follower_id).
    go!
  end
  
  #
  # Returns:
  #   { 
  #     :owner_id => [ club, club ],
  #     :owner_id => [ club ]
  #   }
  #   
  def club_owner_menu
    find.
      lifes.
      clubs.owned.
      group_by(:owner_id).
      map( Club ).
    go!
  end

  # 
  # Returns:
  #   {
  #     :username_id => [ life, life ]
  #     :username_id => [ life ]
  #   }
  def life_menu
    find.
      lifes.
      group_by(:life_id).
      map(Club).
    go!
  end

  # member.lifes.clubs._ids.go!
  #   => Grabs only field, :_id, and maps each doc as: doc['_id']
  #   
  # Returns:
  #   [ club_id, club_id, club_id ]
  #   
  def club_owner_ids
    find.
      lifes.
      clubs.
      map(:_id).
    go!
  end

  # Returns:
  #   :as_owner    => { :usernamed_id => [Clubs] }
  #   :as_follower => { :usernamed_id => [Clubs] }
  #   :as_lifer    => { :usernamed_id => [Clubs] }
  #
  def club_menu 
    raise "Not done"
    { :as_owner => club_owner_menu, 
      :as_follower => mem.club_follower_menu, 
      :as_lifer  => mem.life_menu}
  end

  def lifes
    @lifes ||= begin
                 ls = find.lifes.go!
                 ls.extend Life_Results
               end
  end

  module Life_Results
    
    def usernames
      @usernames ||= map { |doc| doc['username']}
    end
    
    def _ids
      @_ids ||= map { |doc| doc['_id'] }
    end
    
    def _ids_to_usernames
      @_ids_to_usernames ||= begin
                              arr = {}
                               _ids.each_index { |ind|
                                 arr[ _ids[ind] ] = usernames[ind]
                              }
                              arr
                             end
    end
    
  end

end # === model Member



__END__

  attr_reader :old_un, :old_un_id, :current_un, :current_un_id

  make_psuedo :add_username, 
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.'
    [:stripped, /[^a-z0-9_-]{1,}/i, lambda { |s|
        if ['.'].include?( s[0,1] )
          s[0,1]
        else
          ''
        end
      }], 
     [:min, 2, 'Username is too small. It must be at least 2 characters long.'],
     [:max, 20, 'Username is too large. The maximum limit is: 20 characters.'],
     [:not_match, /[^a-zA-Z0-9\.\_\-]/, 'Username can only contain the follow characters: A-Z a-z 0-9 . _ -']
  

  def self.failed_attempts_for_today mem, &blok
    require 'time'
    Failed_Log_In_Attempt.find( 
       :owner_id => mem.data._id,  
       :created_at => { :$lte => Mongo_Dsl.utc_now,
                 :$gte => Mongo_Dsl.utc_string(Time.now.utc - (60*60*24))
       },
       &blok
    ).to_a
  end
  

  

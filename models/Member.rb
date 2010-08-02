require 'bcrypt'

class Member 

	attr_reader :password_reset_code
  attr_reader :old_un, :old_un_id, :current_un, :current_un_id
  
  include Couch_Plastic

  def self.db_collection
    @coll ||= DB.collection('Members')
  end

      
  # =========================================================
  #                     CONSTANTS
  # =========================================================  
  
  Wrong_Password              = Class.new( StandardError )
  Password_Reset              = Class.new( StandardError )
  Password_Not_In_Reset       = Class.new( StandardError )
  Invalid_Password_Reset_Code = Class.new( StandardError )
  Invalid_Security_Level      = Class.new( StandardError )

  SECURITY_LEVELS        = %w{ NO_ACCESS STRANGER  MEMBER  EDITOR   ADMIN }
  SECURITY_LEVELS.each do |k|
    const_set k, k
  end
  
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/

  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."

  enable_timestamps
  
  %w{ 
      update_username
      confirm_password 
  }.each { |fld|
    make_psuedo fld, :not_empty
  }

  [ 
    :hashed_password, 
    :salt
  ].each { |f| make f, :not_empty}
               
  make :security_level, [:in_array, SECURITY_LEVELS]
  
  make :email, 
    :string,
    [:stripped, /[^a-z0-9\.\-\_\+\@]/i ],
    [:match, /\A[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]\Z/ ],
    [:min, 6],
    [:equal, lambda { raw_data.email } ],
    [:error_msg, 'Email has invalid characters.']

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

  def self.delete id, editor
    obj = begin
            by_id(id)
          rescue Member::Not_Found
            nil
          end
    if obj
      super(id, editor)
      db_collection_members_deleted.save(obj.data.as_hash, :safe=>true)
    end
    obj
  end

  def self.valid_security_level?(perm_level)
    return true if SECURITY_LEVELS.include?(perm_level)
    case perm_level
    when BSON::ObjectID, Member, String, Symbol
      true
    else
      false
    end
  end
  
  def self.db_collection_members_deleted
    @coll_members_deleted ||= DB.collection('Members_Deleted')
  end

  def self.db_collection_usernames
    @coll_usernames ||= DB.collection('Member_Usernames')
  end

  def self.db_collection_failed_attempts
    @coll_failed_attempts ||= DB.collection('Member_Failed_Attempts')
  end

  def self.db_collection_password_resets
    @coll_password_resets ||= DB.collection('Member_Password_Resets')
  end

  # ==== Getters =====================================================    
  
  def self.all_usernames_by_id( raw_id )
    db_collection_usernames.find(:$in=>Couch_Plastic.mongofy_id(raw_id))
  end

  def self.add_docs_by_username_id(docs, key = 'owner_id')
    
    # Grab all docs for: usernames, members.
    editor_ids = docs.map { |doc| doc[key] }.compact.uniq
    usernames  = Member.all_usernames_by_id(:$in => editor_ids).to_a
    member_ids = usernames.map { |doc| doc['owner_id'] }
    members    = Member.all_by_id( :$in  => member_ids ).to_a
    
    # Create a Hash: :username_id => :username
    username_map = usernames.inject({}) { |memo, un|
      memo[un['_id']] = un['username']
      memo
    }

    # Create a Hash: :username_id => :member
    editor_map = editor_ids.inject({}) do |memo, ed_id|
      memo[ed_id] = members.detect { |mem| 
                      mem['_id'].to_s == ed_id.to_s
                    }
      memo
    end
    
    # Finally, add corresponding member to target collection.
    docs.each { |doc|
      un_id = doc[key]
      doc['editor_username'] = username_map[ un_id ]
      doc['editor']          = editor_map[ un_id ]
    }
    
  end

  def self.username_doc_by_id(id)
    doc = db_collection_usernames.find_one(:_id=> Couch_Plastic.mongofy_id(id))
    raise Member::Not_Found, "Member username: #{id.inspect}"  unless doc
    doc
  end

  def self.by_email email
    mem = Member.db_collection.find_one(:email=>email)
    if email.empty? || !mem
      raise Not_Found, "Member email: #{email.inspect}"
    end
    Member.by_id(mem['_id'])
  end

  def self.by_username raw_username
    username = raw_username.to_s.strip
    doc = db_collection_usernames.find_one( :username => username )
    if doc && !username.empty?
      Member.by_id(doc['owner_id'])
    else
      raise Not_Found, "Member username: #{username.inspect}"
    end
  end

  def self.by_username_id raw_id
    id = Couch_Plastic.mongofy_id(raw_id)
    doc = db_collection_usernames.find_one(:_id=>id)
    if doc
      Member.by_id(doc['owner_id'])
    else
      raise Couch_Plastic::Not_Found, "Member Username id: #{raw_id.inspect}"
    end
  end

  def self.failed_attempts_for_today mem, &blok
    require 'time'
    db_collection_failed_attempts.find( 
       :owner_id => mem.data._id,  
       :created_at => { :$lte => Couch_Plastic.utc_now,
                 :$gte => Couch_Plastic.utc_string(Time.now.utc - (60*60*24))
       },
       &blok
    ).to_a
  end
  
  # Based on Sinatra-authentication (on github).
  # 
  # Parameters:
  #   raw_vals - Hash with at least 2 keys: :username, :password
  # 
  # Raises: 
  #   Member::Wrong_Password
  #
  def self.authenticate( raw_vals )

    username   = (raw_vals[:username] || raw_vals['username']).to_s.strip
    password   = (raw_vals[:password] || raw_vals['password']).to_s.strip
    ip_addr    = (raw_vals[:ip_address] || raw_vals['ip_address']).to_s.strip
    user_agent = (raw_vals[:user_agent] || raw_vals['user_agent']).to_s.strip
    
    ip_addr    = nil if ip_addr.empty?
    user_agent = nil if user_agent.empty?

    if username.empty? || password.empty?
      raise Wrong_Password, "#{raw_vals.inspect}"
    end

    mem = Member.by_username( username )

    # Check for Password_Reset
    raise Password_Reset, mem.inspect if mem.password_in_reset?

    # See if password matches with correct password.
    correct_password = BCrypt::Password.new(mem.data.hashed_password) === (password + mem.data.salt)
    return mem if correct_password

    # Grab failed attempt count.
    fail_count = Member.failed_attempts_for_today(mem).count
    new_count  = fail_count + 1
    
    # Insert failed password.
    db_collection_failed_attempts.insert(
      { :data_model => 'Member_Failed_Attempt',
      :owner_id   => mem.data._id, 
      :date       => Couch_Plastic.utc_date_now, 
      :time       => Couch_Plastic.utc_time_now,
      :created_at => Couch_Plastic.utc_now,
      :ip_address => ip_addr,
      :user_agent => user_agent },
      :safe => false
    )

    # Raise Account::Reset if necessary.
    if new_count > 2
      mem.reset_password
			raise Password_Reset, mem.inspect
    end

    raise Wrong_Password, "Password is invalid for: #{username.inspect}"
  end 

  def self.add_owner_usernames_to_collection raw_coll
    
    coll = raw_coll.is_a?(Array) ? raw_coll : raw_coll.to_a

    un_ids = coll.map { |c| c['owner_id'] }.uniq.compact
    usernames = db_collection_usernames.find(:_id=>{ :$in => un_ids }).inject({}) { |m, doc|
      m[doc['_id']] = doc
      m
    }
    coll.map { |c|
      target = usernames[c['owner_id']]
      if target
        c['owner_username'] = target['username']
      else
        c['owner_username'] = nil
      end
      c
    }
  end

  # ==== Authorizations ====

  def allow_as_creator? editor # NEW, CREATE
    return true if !editor
    false
  end

  def self.create editor, raw_raw_data # CREATE
    d = new do
      self.manipulator = editor
      self.raw_data = raw_raw_data
      
      new_data.security_level = Member::MEMBER
      ask_for :email
      demand  :add_username, :password
      un_id = nil
      save_create :if_valid => lambda { 
        un_id = __prep_new_username__
      }
      __complete_new_username__ un_id
    end
  end

  def __prep_new_username__
    add_unique_key 'username', "Username, #{clean_data.add_username}, already taken."
    self.class.db_collection_usernames.insert(
      { :username   => clean_data.add_username,  
        :owner_id   => nil}, 
        :safe=>true
    )
  end

  def __complete_new_username__ un_id
    self.class.db_collection_usernames.update(
      {'_id'=>un_id}, 
      {:username=>clean_data.add_username, :owner_id=>data._id}, 
      :safe=>true
    )
  end

  def reader? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    return false if !editor
    return true if self.data._id == editor.data._id
    return true if editor.has_power_of?(:ADMIN)
    false
  end

  def self.update id, editor, new_raw_data # UPDATE

    doc = new(id) do
      self.manipulator = editor
      self.raw_data    = new_raw_data
      
      ask_for :add_username 

      if manipulator == self
        ask_for :password  
      end

      if manipulator.has_power_of? ADMIN
        ask_for :security_level
      end
      un_id = nil
      
      save_update :if_valid => lambda {
        if raw_data.add_username
          un_id = __prep_new_username__
        end
      }
      if un_id
        __complete_new_username__ un_id
      end
    end

  end

  def deletor? editor # DELETE
    updator? editor
  end

  # ==== UPDATORS ======================================================
	
	def pass_reset_id 
		"#{data._id}-password-reset"
	end

  def password_reset_doc
    self.class.db_collection_password_resets.find_one(:_id=>pass_reset_id)
  end

	def password_in_reset?
    !!password_reset_doc
	end
  
  def change_password_through_reset raw_opts 
    if not password_in_reset?
      raise Password_Not_In_Reset, "Can't reset password when account has not been reset."
    end
    
    opts                = Data_Pouch.new(raw_opts, :code, :password, :confirm_password)
    all_values_included = opts.code && opts.password && opts.confirm_password
    raise ArgumentError, "Missing values: #{opts.as_hash.inspect}" if not all_values_included

    reset_doc = password_reset_doc
    
    if BCrypt::Password.new(reset_doc['hashed_code']) === (opts.code + reset_doc['salt']) 
      results = Member.update( data._id, self, opts.as_hash ) 
      self.class.db_collection_password_resets.remove(:_id=>pass_reset_id)
      results
    else
      raise Invalid_Password_Reset_Code, "Member: #{data._id}, Code: #{opts.code}"
    end
  end

	def reset_password 

    code = begin
             # Salt and encrypt values.
             chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
             (1..10).inject('') { |new_pass, i|  
               new_pass += chars[rand(chars.size-1)] 
               new_pass
             }
           end
    salt = begin
             # Salt and encrypt values.
             chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
             (1..10).inject('') { |new_pass, i|  
               new_pass += chars[rand(chars.size-1)] 
               new_pass
             }
           end

    hashed_code = BCrypt::Password.create( code + salt ).to_s
    self.class.db_collection_password_resets.save( # Use :save => update OR insert.
      {:_id       => pass_reset_id, 
      :created_at => Couch_Plastic.utc_now, 
      :owner_id   => data._id,
      :salt       => salt,
      :hashed_code => hashed_code
      },
      :safe       => false
    )
    @password_reset_code = code
  
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
      "#<#{self.class}:#{self.object_id} id=[NEW]>"
    else
      "#<#{self.class}:#{self.object_id} id=#{self.data._id}>"
    end
  end
  
  def usernames
    cache[:usernames] ||= username_hash.values
  end

  def username_ids
    cache[:username_ids] ||= username_hash.keys
  end

  def username_hash
    cache[:username_hash] = begin
                                    hsh = {}
                                    self.class.db_collection_usernames.find(:owner_id=>data._id).map { |un| 
                                      hsh[un['_id']] = un['username']
                                    }
                                    hsh
                                  end
  end

  def username_to_username_id str
    username_hash.index(str)
  end

  def username_id_to_username raw_id
    id = Couch_Plastic.mongofy_id(raw_id)
    username_hash[id]
  end

  def has_power_of?(raw_level)

    return true if raw_level == self
    
    if raw_level.is_a?(String) || raw_level.is_a?(BSON::ObjectID)
      return true if usernames.include?(raw_level)
      return true if data._id === raw_level
      return true if username_ids.include?(raw_level)
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

  def within_username un, &blok
    within_username_id username_to_username_id(un, &blok)
  end
  
  # This method makes sure username belongs to member.
  # If not, current username/username_id is set to nil.
  def within_username_id un_id
    @old_un_id           = current_un_id
    @old_un              = current_un
    
    @current_un    = username_id_to_username(un_id)
    @current_un_id = username_to_username_id(current_un)
    
    yield
    @current_un    = old_un
    @current_un_id = old_un_id
  end

  def current_username_ids
    if current_un_id
      [current_un_id]
    else
      username_ids
    end
  end
  alias_method :life_club_ids, :current_username_ids

  def club_ids 
    (life_club_ids + following_club_ids + owned_club_ids)
  end

  def following_club_ids 
    cache["flwng_clb_ids#{current_username_ids.join(',')}"] ||= Club.ids_for_follower_id( :$in => current_username_ids )
  end

  def following_club_id?(club_id)
    club_ids.include?(Couch_Plastic.mongofy_id(club_id))
  end
  
  def owned_club_ids 
    cache["owned_club_ids_#{current_username_ids}"] ||= Club.ids_by_owner_id(:$in=>current_username_ids)
  end
  
  def owned_clubs
    cache[:owned_clubs] ||= Club.by_owner_id(:$in=>current_username_ids)
  end

  def life_club
    cache['life_club_#{un_id}'] ||= Club.life_club_for_username_id(current_username_ids.first, self)
  end

  def life_clubs
    cache['life_clubs'] ||= Club.life_clubs_for_member(self)
  end

  def messages_from_my_clubs 
    Message.latest_by_club_id(:$in=>club_ids)
  end
  
end # === model Member





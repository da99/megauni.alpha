

class Life

  include Go_Mon::Model

  CATEGORIES = %w{ real celebrity pet baby fantasy }
  HREF_NAMESPACE = '/life'
  HREF_PATTERN = [ '/life/%s/', :username]

  enable_timestamps
  make :owner_id, :mongo_object_id #, [:in_array, lambda { manipulator.lifes._ids } ]
  make :title, :anything
  make :username, :unique, 
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
  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."
  
  make :category, [:in_array, CATEGORIES]

  # ==== Hooks ====
    
  # ==== Associations   ====
  
  # belongs_to :owner, Member
  # def owner? mem
  #   data.owner_id == mem ||
  #     (mem.respond_to?(:data) && mem.data._id == data.owner_id)
  # end
  
  has_many :following_clubs, :Club
    # Club.ids_for_follower_id( :$in => current_username_ids )
  # def following_club_id?(club_id)
  #   club_ids.include?(Mongo_Dsl.mongofy_id(club_id))
  # end
  
  has_many :messages, :Message, :owner_id do

    %w{e qa news shop predictions random }.each { |model|
      filter model.to_sym do
        where :message_model, model
      end
    }
    
    where :privacy, 'public'
    limit 10
    sort [:_id, :desc]
  end

  has_many :owned_clubs, :Club
    # Club.ids_by_owner_id(:$in=>current_username_ids)
    # Club.by_owner_id(:$in=>current_username_ids)
  
  belongs_to :owner, :Member

  # ==== Class Methods  ====
    
  class << self

    
  end # === self

  # ==== Authorizations ====
 
  class << self
    
    def create editor, raw_raw_data # CREATE
      super.instance_eval do
        demand :owner_id, :username, :category
        save_create
      end
    end
    
  end # == self

  def allow_to? action, editor
    case action
      when :create
        return false if !editor.is_a?(Member)
        true
      when :read
        owner?(editor)
      when :update
        owner?(editor)
      when :delete
        owner?(editor)
    end
  end

  # ==== Accessors ====

  # Searches for clubs being followed 
  #   or owned by life.
  #   
  # Returns:
  #   [ club_id, club_id, club_id ]
  #
  def club_ids
    (owned_clubs.map(:club_id).go! +
      club_follows.map(:club_id).go!
    ).uniq
  end
 
  # da01tv.lifes.clubs.map(:filename).go!
  # 
  # Returns: 
  #   [ club_filename, club_filename, club_filename ]
  #   
  def club_filenames
    (owned_clubs.map(:filename).go! +
      club_follows.grab(Club).map(:filename).go!
    ).uniq
  end
  
  # ==== Modules    ====

  module Results
    
    # Returns: 
    #   Hash
    #     :username_id => username
    #     :username_id => username
    #     :username_id => username
    #
    def _ids_to_usernames
      @ids_to_usernames_hash ||= \
        inject({}) { |hsh, un| 
          hsh[un['_id']] = begin
                             un['username'].extend Username_Results
                             un['username']
                           end
          hsh
        }
    end
    
    # Returns: 
    #   Hash
    #     :username_id => username
    #     :username_id => username
    #     :username_id => username
    #
    def usernames_to_ids
      @usernames_to_ids ||= _ids_to_usernames.invert
    end
    
    #  Returns:
    #   Array - [ :username_id ]
    #
    def _ids *str
      _ids_to_usernames.keys
    end
    
    # Accepts:
    #    str - Optional. Username as String.
    #
    # Returns: 
    #    nil 
    #    BSON:ObjectID
    #    
    def _id_for str
        _ids_to_usernames.index(str)
    end
  
    def usernames
      _ids_to_usernames.values
    end

    # Accepts:
    #    raw_id - BSON::ObjectId or legal String
    #             to be turned into a BSON::ObjectId.
    #
    # Returns: 
    #    nil or String.
    #    
    def username_for raw_id
      id = Mongo_Dsl.mongofy_id(raw_id)
      _ids_to_usernames[id]
    end

    # Accepts:
    #   un_ids - Optional. Array [
    #     username_id
    #     username_id
    #   ]
    #
    # Returns:
    #   Array - [
    #     { 
    #       'username_id'   => id, 
    #       'username'      => un, 
    #       'selected?'     => Boolean,
    #       'not_selected?' => Boolean
    #     }
    #   ]
    #
    def menu un_ids = []
      _ids_to_usernames.map { |id, un|
        { 
          'username_id'   => id,
          'username'      => un,
          'href'      => Life.href_for(un),
          'selected?'     => un_ids.include?(id),
          'not_selected?' => !un_ids.include?(id)
        }
      }
    end

    def clubs  un_id, type = nil
      @all_clubs ||= begin
                       Club.hash_for_member(self).values.uniq
                     end
      return @all_clubs if not type
      @all_clubs[type]
    end
    
    def club_ids 
      (lifes.clubs._ids + lifes.following_clubs._ids + lifes.owned_clubs._ids)
    end

    def messages_from_my_clubs 
      Message.latest_by_club_id(:$in=>club_ids)
    end

    # Returns:
    #   :as_owner    => { :usernamed_id => [club doc] }
    #   :as_follower => { :usernamed_id => [club doc] }
    #   :as_lifer    => { :usernamed_id => [club doc] }
    #
    def multi_verse
      # return @multi_verse ||= Club.all_for_member_by_relation(self)
      owned_clubs.as_hash + following_clubs.as_hash + lifes.as_hash
    end
    
    # Accepts:
    #   args - Multiple. Example:
    #     :as_owner
    #     :as_lifer
    #     :as_follower
    #
    # Raises:
    #   ArgumentError - If args has a value not listed above.
    #   
    # Returns:
    #   Hash - {
    #     :username_id => [club doc, club doc]
    #     :username_id => [club doc, club doc]
    #     :username_id => [club doc, club doc]
    #   }
    #
    def multi_verse_per_username_id *args
      valid_types =  [:as_owner, :as_lifer, :as_follower]
      
      types = if args.empty?
                valid_types
              else
                invalid_types = args - valid_types
                raise ArgumentError, "Invalid types: #{invalid_types.inspect}" if not invalid_types
                args
              end
      
      hash = {}
      
      multi_verse.each { |rel, un_id_clubs|
        if types.include?(rel)
          un_id_clubs.each { |un_id, clubs|
            hash[un_id] ||= []
            hash[un_id] += clubs
            hash[un_id] = hash[un_id].uniq
          }
        end
      }
      hash
    end
    
    # Returns:
    #   :username => [Club, Club].uniq
    #   :username => [Club, Club].uniq
    #   :username => [Club, Club].uniq
    #
    def multi_verse_per_username *args
      hash = {}
      multi_verse_per_username_id(*args).each { |k,v|
        hash[lifes.username_for(k)] = v
      }
      hash
    end
    
    # Accepts:
    #   Hash - Optional. {
    #     :username_id => [:club_id, :club_id]
    #     :username_id => [:club_id, :club_id]
    #   }
    #
    # Returns:
    #   Array - [
    #     { 
    #       'username_id'   => id 
    #       'username'      => un 
    #       'clubs'         => [ {
    #                           'selected?'     => Boolean
    #                           'not_selected?' => Boolean
    #                           '_id'           => 
    #                           'filename'      =>
    #                          } ]
    #     }
    #   ]
    #
    def multi_verse_menu selected = {}
      cache_name = selected.empty? ? '{}' : selected.object_id
      multi      = multi_verse_per_username_id( :as_owner, :as_lifer )
      
      multi.map { |un_id, club_arr|
        hash = { 
          'username_id' => un_id,
          'username'    => lifes.username_for(un_id),
          'clubs'       => club_arr.map { |doc|
                            doc['selected?'] = (selected[un_id] || []).include?( doc['_id'] )
                            doc['not_selected?'] = !doc['selected?']
                            doc
                          }
        }
        hash
      }
    end

  end # === module Results
  
  module Username_Results

    def href
      Life.href_for self
    end
    
  end # === module 
  
end # === end Life

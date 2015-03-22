

class Member_Reposts

  include Go_Mon::Model

  enable_timestamps
  
  make :message_id, :mongo_object_id
  make :owner_id,   :mongo_object_id
  make :message_model, [:in_array, %w{repost} ]

  # ==== Authorizations ====
  # ==== Authorizations ====
 
  class << self
  end # === self

  def allow_to? action, editor
    case action
    when :create
      false
    when :read
    when :update
    when :delete
    end
  end

  # ==== Accessors ====
    
  # ==== Modules ====

  module Results

    # Accepts:
    #    Member - Required.
    #
    #  Returns:
    #    Array - {
    #      'owner_id' => [ club_id, club_id]
    #      'owner_id' => [ club_id, club_id]
    #    }
    def usernames
      inject({}) { |memo, doc|
        memo[ doc['owner_id'] ] ||= []
        memo[ doc['owner_id'] ] += doc['target_ids']
        memo
      }
    end
    
    # Accepts:
    #   Member - Required.
    #   
    # Returns:
    #   Array - [
    #     { 
    #       :username_id   => id 
    #       :username      => un 
    #       :clubs         => [ {
    #                          :selected?     => Boolean
    #                          :not_selected? => Boolean
    #                         } ]
    #     }
    #   ]
    def menu
      multi_verse_menu(
        mem.lifes.usernames
      )
    end
    
  end # === module
  

end # === end Member_Reposts

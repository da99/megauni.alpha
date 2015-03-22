

class Member_Notifys

  include Go_Mon::Model

  enable_timestamps
  
  make :something, :anything

  # ==== Authorizations ====
 
  class << self
  end # === self

  def allow_to? action, editor # NEW, CREATE
    case action
      when :create
        false
      when :read
        false
      when :update
        false
      when :delete
        false
    end
  end
  

  # ==== Accessors ====

  # ==== Modules ======

  module Results
    
    # Accepts:
    #    Member - Required.
    #
    #  Returns:
    #    Array - [
    #      owner_id
    #      owner_id
    #    ]
    def usernames
      map { |doc| doc['owner_id'] }
    end
    
    # Accepts:
    #   Message - Optional.
    #   
    # Returns:
    #   Array - [
    #     {
    #       'username_id'   => id
    #       'username'      => un
    #       'selected?'     => Boolean
    #       'not_selected?' => Boolean
    #     }
    #   ]
    def menu
      mem.lifes.menu(
        usernames
      )
    end

  end # === module
  

end # === end Member_Notifys

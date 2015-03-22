

class Follow

  include Go_Mon::Model

  enable_timestamps
  
  make :_id, [:set_to, lambda { "#{new_data.club_id}-#{new_data.follower_id}" }]
  make :target_class, :anything
  make :target_id, :mongo_object_id
  make :follower_id, :mongo_object_id
  
  # ==== Associations   ====
  belongs_to :target do
    child_class :target_class
    foreign_key :target_id
  end
  
  filter_by :clubs do
    where :target_class, 'Club'
  end

  belongs_to :follower, Member, :follower_id 

  # ==== Authorizations ====
 
  def allow_to? action, editor # NEW, CREATE
    case action
    when :create
      true
    when :read
      true
    when :update
      true
    when :delete
      true
    end
  end

  class << self

    def create editor, raw_raw_data
      super.instance_eval do
        demand :_id, :target_class, :target_id, :follower_id
        save_create
      end
    end

  end # == self

  # ==== Accessors ====

  
end # === end Follow

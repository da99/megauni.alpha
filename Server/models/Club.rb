require 'models/Message'

class Club

  include Go_Mon::Model
  
  HREF_NAMESPACE = '/uni'
  HREF_PATTERN   = [ '/uni/%s/', 'filename' ]
  HREF_SUFFIXES  = %w{ follow e magazine news qa shop random thanks fights delete_follow members }

  MEMBERS = %w{ 
    stranger
    member
    insider
    owner
  }.map(&:to_sym)

  INVALID_FILENAMES = File.read('models/INVALID_FILENAMES.txt').
                        split.
                        map(&:strip).
                        map { |str|
                          [str, str + 's']
                        }.flatten

  # ======== Fields ======== 
    
  enable_created_at

  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.lifes._ids }]
  make :filename, 
       [:stripped, /[^a-zA-Z0-9\_\-\+]/ ], 
       :not_empty,
       [:not_in_array, INVALID_FILENAMES],
       :unique
  make :title, :not_empty
  make :teaser, :not_empty

  # ======== Associations   ======== 
  
  has_many :messages do
    
    foreign_key :target_ids
    where :parent_message_id, nil
    where :privacy, 'public'
    limit 10
    sort  [:_id, :desc]
    
    filter :questions do
      where :message_model, 'question'
    end

    filter :news do
      where_in :message_model, %w{ news }
    end
    
    filter :magazine do
      where_in :message_model, %w{mag_story}
    end

    filter :passions do
      where_in :message_model, %w{fight complaint debate}
    end
    
    filter :facts do
      where_in :message_model, ['e_chapter', 'e_quote']
    end
    
    filter :buys do
      where :message_model, 'buy'
    end

    filter :predictions do
      where :message_model, 'prediction'
    end
    
    filter :randoms do
      where :message_model, 'random'
    end
    
    filter :thanks do
      where :message_model, 'thank'
    end

  end


  # ======== Authorizations ======== 

  class << self
    
    def create editor, raw_raw_data # CREATE
      raw_raw_data['owner_id'] ||= editor.lifes._ids.first
      super.instance_eval do
        demand :owner_id, :filename, :title, :teaser
        ask_for_or_default :lang
        save_create 
      end
    end

    def update id, editor, new_raw_data # UPDATE
      super.instance_eval do
        ask_for :title, :teaser
        save_update 
      end
    end
    
  end # == self

  def allow_to? action, editor
    case action
      
      when :create
        return false if not new?
        return true if editor.has_power_of? :MEMBER
        
      when :read
        true
        
      when :update
        editor.has_power_of?(:ADMIN) ||
          editor.has_power_of?(data.owner_id)
        
      when :delete
        owner? editor
    end
  end

  # ======== Class Methods ======== 
  
  # class << self 
  # end # === self

  # ======== Accessors ======== 

  # class << self 
  # end # === self

  def owner?(mem)
    return false if not mem
    mem.lifes._ids.include?(data.owner_id)
  end

  def followers
    (find_followers(:club_id=>data._id).map { |doc|
      doc['follower_id']
    } + [data.owner_id])
  end

  def potential_follower? mem
    !follower?(mem)
  end

  def follower? mem
    mem.following_club_id?(data._id)
  end

  module Results
    
    def href
      first.href
    end

  end # === module

end # === Club

__END__

    

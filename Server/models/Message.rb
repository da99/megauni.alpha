# put public_labels into own Collection
#   -> authors, insiders, strangers will be tagging records
#   -> making them embedded is wrong.
# put old_id into hard code, on this file
# take :created_at for old_id and turn them into ObjectIDs, make them :_id
    # def by_old_id id
    #   old_id = "message-#{id}"
    #   mess = find_one(:old_id=>old_id)
    #   if mess
    #     by_id(mess['_id'])
    #   else
    #     by_id(old_id)
    #   end
    # end


class Message

  DECLINE = -1
  PENDING = 0
  ACCEPT  = 1
  HREF_NAMESPACE = '/mess/'
  HREF_PATTERN = ['/mess/%s/', :_id]
  HREF_SUFFIXES = %w{ notify repost edit log } + 
                  [['parent', :parent_message_id], 
                   ['section', :message_section_suffix]] 

  module SECTIONS
    E      = 'Encyclopedia'
    R      = 'Random'
    F      = 'Fights'
    PREDICTIONS = 'Predictions'
    RANDOM = 'RANDOM'
    MAG    = 'Magazine'
    NEWS   = 'News'
    QA     = 'Q & A'
    SHOP   = 'Shop'
    FIGHTS = 'Fights'
    THANKS = 'Thanks'
  end

  MODEL_HASH = {
    'news' => ['important news', SECTIONS::NEWS],
    'comment' => ['comment'],
    'random' => ['random info.', SECTIONS::R],
    'fight' => ['fight', SECTIONS::F],
    'debate' => ['friendly debate', SECTIONS::F],
    'complaint' => ['complaint', SECTIONS::F],
    'prediction' => ['prediction', SECTIONS::PREDICTIONS],
    'mag_story'  => ['magazine article', SECTIONS::MAG],
    'question'   => ['question', SECTIONS::QA],
    'cheer'      => ['cheer reply', SECTIONS::THANKS],
    'jeer'      => ['critique reply', SECTIONS::THANKS],
    'suggest'      => ['suggestion', SECTIONS::THANKS],
    'e_chapter' => ['encyclopedia chapter', SECTIONS::E],
    'e_quote' => ['quotation', SECTIONS::E],
    'buy'     => ['buy it', SECTIONS::SHOP],
    'thank'   => ['thanks', SECTIONS::THANKS],
    'repost'  => ['repost', 'everywhere']
    # plea  
    # fulfill
    # event
  }
  
  MODELS = MODEL_HASH.keys
  
  include Go_Mon::Model

  enable_timestamps
  
  # make_psuedo :editor_id, :mongo_object_id, [:in_array, lambda { manipulator.lifes._ids } ]

  make :message_model, [:in_array, MODELS]
  make :important, :not_empty
  make :rating, :not_empty
  make :privacy, [:in_array, ['private', 'public', 'friends_only'] ]
  # make :owner_id, :life_id #, :mongo_object_id, [:in_array, lambda { manipulator.lifes._ids } ]
  make :parent_message_id, :mongo_object_id, [:set_raw_data, [:target_ids, lambda { 
    mess = Message.by_id(raw_data.parent_message_id)
    mess.data.target_ids
  }]]
  make :target_ids    , :split_and_flatten, :mongo_object_id_array
  make :emotion       , :not_empty
  make :category      , :not_empty
  make :labels        , :split_and_flatten, :array
  make :public_labels , :split_and_flatten, :array
  make :private_labels, :split_and_flatten, :array
  make :title         , :anything
  make :answer        , :anything
  make :teaser        , :anything
  make :published_at  , :datetime_or_now
  make :body          , :not_empty
  make :owner_accept, :require_owner_as_manipulator, :integer, [ :in_array, [DECLINE, PENDING, ACCEPT]]
  make :body_images_cache, [:set_to, lambda { 
    # turn "URL 100 100" into 
    # ==> [URL, 100, 100]
    # ==> BSON won't allow URL as key because it contains '.'
    raw_data.body_images_cache.to_s.split("\n").map { |val|
      url, width, height = val.split.map(&:strip)
      [url, width.to_i, height.to_i]
    }
  }]

  # ==== Associations   ====

  # finder :public do
  #   limit 10
  #   sort  [:_id, :desc]
  #   relations :optional, Life, Club
  # end

  belongs_to :owner, :Life

  has_many :clubs, nil, :target_ids
  
  # has_many :reposts, Message do 
  #   where_in :owner_id, mem.lifes._ids
  #   where    :message_model, 'repost'
  # end
  # 
  # has_many :notifys, :Member_Notifys do |mem|
  #   where_in :owner_id, mem.lifes._ids
  # end
  
  has_many :responds, Message, :parent_message_id do
    
    where :privacy , 'public'
    limit 10
    sort  [:_id, :desc]
    
    filter :critiques do
      where_in :message_model, ['cheer', 'jeer']
    end
    
    filter :suggests do
      where :message_model, 'suggest'
    end
    
    # filter :questions do
    #   where :message_model, 'question'
    # end
    
  end

  has_many :messages, Message, :parent_message_id do

    override_as :comments do
      where_in :message_model, %w{ jeer cheer }
    end

    override_as :questions do
      where :message_model, 'question'
    end
  
    where :privacy, 'public'
    limit 10
    sort  [:_id, :desc]
  end
  
  # ==== Authorizations ====
    
  creator :owner do
    # set default for: 
    # labels, public_labels, lang
    
    demand :owner_id, :target_ids, :body, :message_model
    ask_for :title, :category, :privacy, :labels,
      :emotion, :rating,
      :labels, :public_labels,
      :important,
      :body_images_cache, 
      :parent_message_id, :lang
  end
  
  reader :all

  updator :owner, :Admin do
    ask_for :title, :body, :teaser, :public_labels, 
      :private_labels, :published_at,
      :message_model, :important,
      :body_images_cache,
      :editor_id,
      :owner_accept
    save :diff
  end

  deletor :owner

  # class << self
  #   
  #   def create editor, raw_data
  #     d = new do
  #       self.manipulator = editor
  #       self.raw_data = raw_data
  #       new_data.labels = []
  #       new_data.public_labels = []
  #       ask_for_or_default :lang
  #       ask_for :parent_message_id
  #       demand :owner_id, :target_ids, :body, :message_model
  #       ask_for :title, :category, :privacy, :labels,
  #           :emotion, :rating,
  #           :labels, :public_labels,
  #           :important,
  #           :body_images_cache
  #       save_create 
  #     end
  #   end

  #   def update id, editor, new_raw_data
  #     doc = new(id) do
  #       self.manipulator = editor
  #       self.raw_data    = new_raw_data
  #       ask_for :title, :body, :teaser, :public_labels, 
  #         :private_labels, :published_at,
  #         :message_model, :important,
  #         :body_images_cache,
  #         :editor_id,
  #         :owner_accept
  #       save_update :record_diff => true
  #     end
  #   end


  # end # === self

  # def allow_to? action, editor # NEW, CREATE
  #   case action
  #   when :create
  #     return false unless editor
  #     editor.has_power_of? :MEMBER
  #   when :read
  #     true
  #   when :update
  #     owner? editor
  #   when :delete
  #     owner? editor
  #   end
  # end

  # ==== Accessors ====
  
  # ==== Class Methods ====

  class << self

    def news
      club_id = Club.db.collection.find_one(:filename=>'megauni')['_id']
      find.target_ids(club_id).privacy('public').sort(['_id', :asc])
    end

    def message_model?( str_or_hash )
      case str_or_hash
      when String
        MODELS.include?(str_or_hash)
      when Hash
        !!(str_or_hash.values.flatten.detect { |mod| MODELS.include?(mod) })
      else
        raise ArgumentError, "Unknown type: #{str_or_hash}"
      end
    end

    def selector_validation selector
      mess_model = selector[:message_model] || selector['message_model']
      if mess_model && !message_model?(mess_model)
          raise ArgumentError, "Invalid message model #{mess_model.inspect}" 
      end
      selector
    end

  end # === self
  
  
  # ==== Accessors =====================================================

  def product?
    data.public_labels && data.public_labels.include?('product')
  end

  def published_at
    Time.parse(data.published_at || data.created_at)
  end

  def last_modified_at
    latest = [data.created_at, data.updated_at, data.published_at].compact.sort.first
    Time.parse(latest)
  end

  def message_section_suffix
    case message_section
    when Message::SECTIONS::E
        'e'
    when Message::SECTIONS::QA
        'qa'
    else
      message_section.to_s.downcase.split.join('_')
    end
  end

  def message_section
    if data.message_model
      Message::MODEL_HASH[data.message_model][1]
    else
      'Unknown'
    end
  end
  
  def message_model_in_english
    if data.message_model
      Message::MODEL_HASH[data.message_model].first 
    else
      'unkown'
    end
  end

  module Result
  
    def published_at
      Time.parse( fetch('published_at') || fetch('created_at') )
    end
    
    def last_modified_at
      latest = [ fetch('created_at'), fetch('updated_at'), fetch('published_at')].
                compact.
                sort.
                first
      Time.parse(latest)
    end

  end # === module
  
  include Result

end # === end Message



__END__

    # def public_labels target_ids = nil
    #   map = %~
    #     function () {
    #         for (var i in this.tags) {
    #             emit(this.tags[i], {total:1});
    #         }
    #     };
    #   ~
    #   reduce = %~
    #     function (key, value) {
    #         var sum = 0;
    #         value.forEach(function (doc) {sum += doc.total;});
    #         return {total:sum};
    #     };
    #   ~
    #   opts = if target_ids
    #            { :query => { :target_ids=> { :$in=>target_ids}} }
    #          else
    #            { :query => { :tags => { :$ne => nil } } }
    #          end
    #   
    #   db_collection.map_reduce(map, reduce, opts).find().map { |doc| doc['_id'] }
    # end

    


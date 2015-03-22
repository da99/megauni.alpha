# models/Club.rb
require 'views/Club_Control_Base_View'
require 'models/Wash'

class Clubs
  
  include Base_Control
  OLD_TOPICS = Find_The_Bunny::Old_Topics
  SECTIONS   = %w{ e qa news fights shop random thanks predictions magazine}
  
  top_slash # =====================================================
  
  redirect('/club-search').to('/search')

  path '/search' # =====================================================

  get '/:cgi_escape', :STRANGER do
    render :text, "Not done."
  end

  get '/', :STRANGER do
    action :search

    the.club_filename = filename
    begin
      club = Club.find.filename(filename).go_first!
      redirect! club.href
    rescue Club::Not_Found
    end
    
    template
  end

  post '/', :STRANGER do
    filename = clean_room['keyword'].to_s
    begin
      club = Club.find.filename(filename).go_first!
      redirect! club.href
    rescue Club::Not_Found
      begin
        life = Life.find.username(filename).go_first!
        redirect! life.href
      rescue Life::Not_Found
        redirect! "/search/#{Wash.url_escape(filename)}/" 
      end
    end
  end

  top_slash # =====================================================
  
  get '/uni-new', :MEMBER do
    action :new
    render :html
  end

  post '/uni-create', :MEMBER do
    begin
      club = Club.create( current_member, clean_room )
      flash_msg.success = "Club has been created: #{club.data.title}"
      redirect! club.href
    rescue Club::Invalid
      flash_msg.errors = $!.doc.errors
    end
    
    redirect_back_or '/uni-new'
  end
  
  redirect('/uni/').to('/unis/')
  path '/unis' # =====================================================
  
  get '/', :STRANGER do
    action :list
    the.clubs = Club.all
    template 
  end
  
  path '/uni/:filename' # =====================================================

  get '/', :STRANGER do # by_old_id id
    action :by_old_topic
    old_topic = clean_room['filename']
    pass unless OLD_TOPICS.include?(old_topic)
    
    the.club = old_topic
    template "Topic_#{old_topic}.html"
  end

  get '/', :STRANGER do # by_filename filename
    action :by_filename
    filename            = clean_room['filename']  
    the.club            = club = Club.find.filename(filename).go_first!
    the.latest_messages = Message.find.
                            target_ids(club.data._id).
                            sort([:_id, :desc]).
                            limit(10).
                            merge(:owner).
                            fields(:username).
                          go!
    case filename
    when 'hearts'
      template "Clubs_#{filename}.html"
    else
      template :html
    end
  end
  
  put '/', :MEMBER do # update filename
    the.club = Club.find.filename(filename).fields(:_id).go_first!
    club_id  = the.clud.data._id
    begin
      the.club.update(current_member, clean_room)
      flash_msg.success = "Club has been updated."
      redirect! club.href
    rescue Club::Invalid
      flash_msg.errors = $!.doc.errors
      redirect! club.href_edit
    end
  end

  get '/edit', :MEMBER do # club_filename
    action :edit
    the.filename = clean_room[:filename]
    the.club = Club.find.filename(the.filename).go_first!
    require_log_in! :ADMIN, the.club.data.owner_id
    template :html
  end

  get '/follow', :MEMBER do
    filename = clean_room[:filename]
    clean_room['username'] = current_member.lifes.usernames.first
    clean_room['filename'] = filename
    POST_follow()
  end

  post '/follow', :MEMBER do
    username_id = current_member.lifes.username(clean_room['username']).fields().go_first!
    club        = Club.find.filename(clean_room['filename']).go_first!
    begin
      club.create_follower(current_member, username_id)
    rescue Club::Invalid
      flash_msg.errors = $!.doc.errors
    end
    redirect! club.href
  end
  
  get :news, :STRANGER do
    the_club_with :news
    template :html
  end

  get :magazine, :STRANGER do
    the_club_with :magazine
    template :html
  end

  get :fights, :STRANGER do
    the_club_with :passions
    template :html
  end

  get :qa, :STRANGER do
    the_club_with :questions
    template :html
  end

  get :e, :STRANGER do
    the_club_with :facts
    template :html
  end

  get :shop, :STRANGER do
    the_club_with :buys
    template :html
  end

  get :predictions, :STRANGER do
    the_club_with :predictions
    template :html
  end

  get :random, :STRANGER do
    the_club_with :randoms
    template :html
  end

  get :thanks, :STRANGER do
    the_club_with :thanks
    template :html
  end
  
  # =========================================================
  #               READ-related actions
  # =========================================================

  %w{ /:year /:year/:month }.each { |url|
    
    get url, :STRANGER do  # by_date
      
      year, month, prev_month, next_month = stardardize_date_ranger( clean_room[:year], clean_room[:month])
      case month
        when 1
          @prev_month = Time.utc(year - 1, 12)
          @next_month = Time.utc(year + 1, 2)
        when 12
          @prev_month = Time.utc(year, 11)
          @next_month = Time.utc(year, 1)
        else
          @prev_month = Time.utc(year, month-1)
          @next_month = Time.utc(year, month+1)    
      end
      
      @date = Time.utc(year, month)
      
      the.messages = Club.find.messages.
        news.
        published_at.
        between(prev_month, next_month).
        sort( [:_id, :desc] ).
        go!
      
      template "Clubs_by_date.html"
      
    end
    
  } # === %w{}

end # === Club_Control



__END__


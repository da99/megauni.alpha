
class Messages
  
  include Base_Control

  top_slash # ===========================================================

  get '/uni/:club_filename/:label', :STRANGER  do
    action :by_label
    
    the.club_filename = clean_room[:club_filename]
    the.label         = clean_room[:label]
    the.club          = Club.find._id(the.club_filename).go_first!
    the.messages      = Message.by_club_id_and_public_label(club.data._id, label)
    
    template :html
  end
  
  get '/uni/:club_filename/:year/:month', :STRANGER do |club_filename, year, month|
    action :by_date

    the.year     = year
    the.month    = month
    the.club     = Club.find.filename(club_filename).go_first!
    the.messages = the.club.find.
      messages.
      published_at.between(year, month).
      go!
    
    template :html
  end

  post '/messages', :MEMBER do # CREATE
    begin
      mess = Message.create( current_member, clean_room )
      flash_msg.success = "Your message has been saved."
      redirect! mess.href
    rescue Member::Invalid
      flash_msg.errors= $!.doc.errors 
    end
    
    redirect_back_or '/lifes/'
  end
  
  path "/mess/:id" # ===========================================================

  get '/', :STRANGER do
    action :show
    the_message
    template :html
  end

  get :history, :ADMIN do
    the_message
    template :html
  end


  post :notify, :MEMBER do |mess_id|
    render :text, clean_room.inspect
  end

  post :repost, :MEMBER do 
    render :text, clean_room.inspect
  end

  # def PUT id # UPDATE
  #   success_msg(lambda { |doc| "Update: #{doc.data.title}" })
  #   params = clean_room.clone
  #   params[:tags] = begin
  #                     new_tags = []
  #                     new_tags += clean_room[:new_tags].to_s.split("\n") 
  #                     new_tags += clean_room[:tags]
  #                     new_tags.uniq
  #                   end
  #   handle_rest :params=>params
  # end

  put '/', :MEMBER do |id|
    mess_id = if id.to_s.size < 8
                "message-#{id}"
              else
                id
              end
    begin
      mess = Message.update( mess_id, current_member, clean_room )
      flash_msg.success = "Message saved."
      redirect_back! "/mess/#{id}/"
    rescue Message::Invalid
      flash_msg.errors = $!.doc.errors
      redirect_back! "/mess/#{id}/edit/"
    end
  end
  
  get :edit, :MEMBER do |id|
    mess_id = if id.to_s.size < 8
                "message-#{id}"
              else
                id
              end
    mess = env['results.message'] = Message.by_id(mess_id)
    require_log_in! 'ADMIN',  mess.data.owner_id
    render_html_template
  end

  delete '/', :MEMBER do
    success_msg { "Delete: #{doc.data.title}"  }
    redirect_success '/my-work/' 
    crud! 
  end

  private
  def id_to_mess raw_id
    id = raw_id.to_s.strip
    env['message_by_id'] = if id.size < 6
                             Message.by_old_id(id)
                           else
                             Message.by_id(id)
                           end
  end

end # === class

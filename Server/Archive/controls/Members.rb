require 'helpers/Pony'

class Members
  include Base_Control
    
  # ============= Member Actions ==========================          

  top_slash # =============================================
  
  get '/create-account', :STRANGER do
    action :create_account
    template :html
  end

  get '/create-life', :MEMBER do
    action :new_life
    template :html
  end
            
  post '/create-account', :STRANGER do
    log_out! 

    begin
      clean_room[:add_life] ||= 'friend'
      m = Member.create( current_member, clean_room )
      self.current_member = m
      flash_msg.success = "Your account has been created."
      redirect! '/lifes/' 
      
    rescue Member::Invalid

      flash_msg.errors= $!.doc.errors 
      session[ :form_username  ] = clean_room[:username] 
               
      redirect! '/create-account' 
    end
      
  end # == post :create


  # =========================== MEMBER ONLY ==========================================

  get :today, :MEMBER do
    template :html
  end
  
  get :follows, :MEMBER do
    template :html
  end
  
  get :notifys, :MEMBER do
    template :html
  end

  get :lifes, :MEMBER do
    template :html
  end

  path "/life/:filename" # ======================================
  
  get '/', :STRANGER do
    action :life
    the_life
    template :html
  end

  %w{e qa news shop predictions random }.each { |path|
    get path.to_sym, :STRANGER do
      action :"life_#{path}"
      the_life_with path.to_sym
      template :html
    end
  }

  redirect( "../status" ).to( "../news") 
  
  top_slash # ==================================================
  
  post '/reset-password', :STRANGER do 
  
    the.email = clean_room['email']
    
    begin
      mem       = Member.find.email( clean_room['email'] ).go_first!
      code      = mem.reset_password
      env['results.reset'] = true
      reset_url = File.join(Uni_App::SITE_URL, "change-password", code, CGI.escape(mem.data.email), '/')
      Pony.mail(
        :to    =>clean_room['email'], 
        :from  =>Uni_App::SITE_HELP_EMAIL, 
        :subject=>"#{Uni_App::SITE_DOMAIN}: Lost Password",
        :body  =>"To change your old password, go to:\n#{reset_url}"
        # :via      => :smtp,
        # :via_options => { 
        #   :authentication => Uni_App::SMTP_AUTHENTICATION,
        #   :address   => Uni_App::SMTP_ADDRESS,
        #   :user_name => Uni_App::SMTP_USER_NAME,
        #   :password  => Uni_App::SMTP_PASSWORD,
        #   :domain    => Uni_App::SMTP_DOMAIN
        # }
      )
    rescue Member::Not_Found
    end
      
    template :html
  end

  get '/change-password/:code/:email', :STRANGER do
    action :change_password
    the.member = Member.find.email(CGI.unescape(email)).go_first!
    the.code   = code
    the.email  = email
    template :html
  end

  post '/change-password/:code/:email', :STRANGER do
    mem = Member.find.email(CGI.unescape(email)).go_first!
    begin
      mem.change_password_through_reset(
        :code=>code, 
        :password=>clean_room[:password], 
        :confirm_password=>clean_room[:confirm_password]
      )
      flash_msg.success = "Your password has been updated."
      redirect! '/log-in/'
    rescue Member::Invalid
      flash_msg.errors = $!.doc.errors
      redirect! "/change-password/#{code}/#{email}/"
    end
  end
        
  put '/update-account', :MEMBER do
    begin
      m = Member.update( current_member.data._id, current_member, clean_room )
      flash_msg.success = "Data has been updated and saved."
      if clean_room['add_username']
        redirect! "/life/#{m.clean_data.add_username}/"
      else
        redirect! '/lifes/'
      end
    rescue Member::Invalid
      flash_msg.errors= $!.doc.errors 
      session[:add_username] = clean_room['add_username']
      redirect_back! "/lifes/"
    end
  end # === put :update

  delete '/delete-account', :MEMBER do
    Member.delete( current_member.data._id, current_member )
    log_out!
    flash_msg.success = "Your account has been deleted forever."
    redirect! '/'
  end

end # === Member_Control


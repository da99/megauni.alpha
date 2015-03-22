class Sessions
  include Base_Control

  top_slash

  get '/log-out', :STRANGER do
    action :log_out
    log_out!
    flash_msg.success =  "You have been logged out." 
    redirect '/'
  end

  get '/log-in', :STRANGER do
    action :log_in
    template :html
  end

  post '/log-in', :STRANGER do
    log_out!
    begin 
      self.current_member = Member.authenticate(
        :username   => clean_room['username'], 
        :password   => clean_room['password'], 
        :ip_address => request.env['REMOTE_ADDR'],
        :user_agent => request.env['HTTP_USER_AGENT']
      )
      redirect!( session.delete(:return_page) || '/lifes/' )
      
    rescue Go_Mon::Not_Found, Member::Wrong_Password
      flash_msg.errors = "Incorrect info. Try again."
      
    rescue Password_Reset::In_Reset
      flash_msg.errors = "Your password has been reset. Check your email for instructions." 
      
    end

    redirect! '/log-in/'
       
  end # === post_it_for

end # === Session_Control



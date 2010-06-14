$KCODE = 'utf8'

begin

  require 'mongo_rack'
  require 'helpers/mongo_rack_with_proper_uri_parser'

  %w{
    Allow_Only_Roman_Uri
    Squeeze_Uri_Dots 
    Find_The_Bunny
    Always_Find_Favicon
    Slashify_Path_Ending
    Serve_Public_Folder
    Redirect_Mobile
    Catch_Bad_Bunny
    Email_Exception
    Strip_If_Head_Request
    Flash_Msg
    Old_App_Redirect
  }.each { |middle|
    require "middleware/#{middle}"
  }

  require 'megauni'
  
  my_app_root     = File.expand_path( File.dirname(__FILE__) )
  down_time_file  = File.join( my_app_root, '/helpers/sinatra/maintain')
  issue_client    = File.join( my_app_root, '/helpers/app/issue_client') 
  
  
  # === Protective
  use Rack::ContentLength
  use Allow_Only_Roman_Uri
  use Squeeze_Uri_Dots
  use Slashify_Path_Ending
  use Redirect_Mobile
  use Old_App_Redirect

  
  if The_App.non_production?
    require 'middleware/Render_Css' 
    use Render_Css
  end

  # === Content Generators
  use Always_Find_Favicon
  use Serve_Public_Folder, ['/busy-noise/', '/my-egg-timer/', '/styles/', '/skins/']
  
  # === Helpers
  use Rack::MethodOverride
  use Rack::Session::Mongo, {:server=>File.join(MONGODB_CONN_STRING, DB_SESSION_TABLE) , :expire_after => (60*60*24*14) }
  use Strip_If_Head_Request
  
  # === Low-level Helpers 
  # === (specifically designed to run before The_App).
  use Email_Exception
  use Catch_Bad_Bunny
  use Find_The_Bunny
  use Flash_Msg

    
  # ===============================================
  # Require these controls.
  # ===============================================
  
  %w{
    Hellos
    Sessions
    Members
    Clubs
    Messages
  }.each { |control|
    require "controls/#{control}"
    The_App.controls << Object.const_get(control)
  }

  if The_App.development?
    require "controls/Inspect_Control"
    The_App.controls << Inspect_Control
  end
  
  
  # Finally, start the app.
  run The_App

  
rescue Object => e
  
  if ['test', 'development'].include?(ENV['RACK_ENV'])
    raise e
  else
    begin
      require 'cgi'
      load File.expand_path('~/.megauni_conf')
      Pony.mail(
        :to=>'diego@miniuni.com', 
        :from=>'help@megauni.com',
        :subject => CGI.escapeHTML(e.class.to_s),
        :body    => CGI.escapeHTML(e.message.to_s),
        :via      => :smtp,
        :via_options => { 
          :address   => 'smtp.webfaction.com',
          :user_name => The_App::SMTP_USER_NAME,
          :password => The_App::SMTP_PASSWORD
        }
      )
    rescue Object => x
    end
  end
  
  the_app = lambda { |env|
    
    content = if env['REQUEST_METHOD'] === 'HEAD'
                ''
              elsif env["HTTP_X_REQUESTED_WITH"] === "XMLHttpRequest"
                %~<div class="error">Server Error. Try again later.</div>~
              else
                %~
                  <html>
                    <body>
                      <h1>Server Error.</h1>
                      <p>Try again later.</p>
                    </body>
                  </html>
                ~
              end
    
    [500, {'Content-Type' => 'text/html', 'Content-Length'=>content.size.to_s}, content]
    
  }
  
  run the_app
#   
end # === begin





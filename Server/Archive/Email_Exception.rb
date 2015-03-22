class Email_Exception
  
  def initialize new_app
    @app = new_app
  end
  
  def call new_env
    
    status, headers, body = @app.call( new_env )
    
    if not [200, 301, 302, 303, 304, 307].include?(status)
      e = new_env['the.app.error']
      IssueClient.create(new_env, ENV['RACK_ENV'], e.message, new_env['HTTP_REFERER'], e)
    end
    
    [status, headers, body]
    
  end
  
end # === Email_Exception

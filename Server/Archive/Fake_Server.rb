class Fake_Server
  
  def initialize new_app
    if !['development', 'test'].include?(ENV['RACK_ENV'])
      raise "Can't use this in environment: #{ENV['RACK_ENV'].inspect}"
    end
    @app = new_app
  end
  
  def call new_env
    
    new_env['REQUEST_URI'] ||= begin
      qs = new_env['QUERY_STRING'].to_s.strip.empty? ? nil : new_env['QUERY_STRING']
      [ new_env[ 'PATH_INFO' ], qs].compact.join('?')
    end

    new_env['REQUEST_PATH'] ||= begin
                                  new_env['PATH_INFO']
                                end
    @app.call new_env
  end
  
end # === Allow_Only_Roman_Uri

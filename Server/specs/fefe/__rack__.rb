require 'rack/test'
ENV['RACK_ENV'] = 'test'
require 'middleware/Fake_Server'
require File.expand_path('.').split('/').last  


module FeFe_Test

  include Rack::Test::Methods
   
  def app
    @app ||= begin
               rack    = Rack::Builder.new
               rack.use Fake_Server
               file    = File.expand_path('config.ru')
               content = File.read(file)
               rack.instance_eval(content, file, 1)
               rack.to_app
             end
  end   

  def ssl_hash
    {'HTTP_X_FORWARDED_PROTO' => 'https'}
  end

  def last_response_should_be_xml
    demand_equal 'application/xml;charset=utf-8', last_response.headers['Content-Type']
  end

  def follow_ssl_redirect!
    follow_redirect!
    follow_redirect!
  end

  def log_in_member
    mem = Life.find.username('regular-member-1').grab(:owner).go_first!
    demand_false( mem.has_power_of?( :ADMIN ) )
    post '/log-in/', {:username=>mem.lifes.usernames.first, :password=>'regular-password-1'}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match( /my-work/, last_request.fullpath )
  end

  def log_in_admin
    mem = Life.find.username('admin-member-1').grab(:owner).go_first!
    demand_true mem.has_power_of?( :ADMIN )
    post '/log-in/', {:username=>mem.lifes.usernames.first, :password=>'admin-password-1'}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match( /my-work/, last_request.fullpath )
  end

  
end # ======== FeFe_Test

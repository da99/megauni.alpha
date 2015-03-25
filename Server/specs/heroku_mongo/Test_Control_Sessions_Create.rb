# controls/Sessions.rb
require 'tests/__rack_helper__'

class Test_Control_Sessions_Create < Test::Unit::TestCase

  def username
    'da01'
  end

  def password
    'myuni4vr'
  end

  must 'renders ok on SSL' do
    get '/log-in/', {}, ssl_hash
    assert_equal 200, last_response.status
    assert_match( /Log-in/, last_response.body )
  end

  must 'redirects and displays errors if no information supplied.' do
    post '/log-in/', {}, ssl_hash
    follow_redirect!
    assert_match( /Incorrect info. Try again./, last_response.body)
  end

  must 'redirects and displays errors if user is not found.' do
    post '/log-in/', {:username=>'da-unknown', :password=>'some_password'}, ssl_hash
    follow_redirect!
    assert_match( /Incorrect info. Try again./, last_response.body)
  end

  must 'allows Member access if creditials are correct.' do
    post '/log-in/', {:username=>regular_username(1), :password=>regular_password(1)}, ssl_hash
    follow_redirect!
    assert_equal '/lifes/', last_request.path_info
  end

  must 'won\'t accept any more log-in attempts (even with right creditials) ' +
     'after limit is reached' do
    10.times do |i|
      post '/log-in/', {:username=>'wrong', :password=>'wrong'}, ssl_hash
    end
    post '/log-in/', {:username=>username, :password=>password}, ssl_hash
    follow_redirect!
    assert_equal '/log-in/', last_request.path_info
  end

  must 'show a flash message if password has been reset' do
    pass = "mypass123"
    mem = create_member(:password=>pass, :confirm_password=>pass)
    mem.reset_password
    post '/log-in/', {:username=>mem.lifes.usernames.first, :password=>pass}, ssl_hash
    follow_redirect!
    assert last_response.body['has been reset']
  end

end # === class Test_Control_Sessions_Create

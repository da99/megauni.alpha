# controls/Members.rb

describe :Control_Members_Read do

  it "redirects /today/ to / for non-members" do
    get '/today/', {}, ssl_hash
    follow_redirect!
    assert_equal '/', last_request.fullpath
    assert_equal 200, last_response.status
  end

  # ========== LIFE ============================

  it 'show profile: /life/{username}/' do
    get "/life/da01tv/"
    assert_last_response_ok
  end

  %w{ e qa news shop predictions random }.each { |suffix|
    
    it "redirects /uni/{username}/#{suffix}/" do
      get "/uni/da01tv/#{suffix}/"
      assert_redirect "/life/da01tv/#{suffix}/"
    end

    it "show /life/{username}/#{suffix}/" do
      get "/life/da01tv/#{suffix}/"
      assert_last_response_ok
    end
    
  }

end # === class Test_Control_Members_Read

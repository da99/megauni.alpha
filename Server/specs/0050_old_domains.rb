# middleware/Mu_Archive_Redirect.rb

describe :Control_Old_Apps_Read do

  it 'shows a moving message for www.myeggtimer.com' do
    domain = 'www.myeggtimer.com'
    get '/', {}, { 'HTTP_HOST'=> domain }
    follow_redirect!
    last_response.body.should.match /over to the new address/
  end 

  it 'should redirect www.busynoise.com/ to /busy-noise/moving.html' do
    domain = 'www.busynoise.com'
    get '/', {}, { 'HTTP_HOST' =>domain  }
    follow_redirect!
    assert_equal '/busy-noise/moving.html', last_request.fullpath
  end

  it 'should redirect www.busynoise.com/egg to /busy-noise/moving.html' do
    domain = 'www.busynoise.com'
    get '/egg', {}, { 'HTTP_HOST' =>domain  }
    follow_redirect!
    follow_redirect!
    assert_equal '/busy-noise/moving.html', last_request.fullpath
  end

  it 'shows a moving message for www.busynoise.com/egg/' do
    domain =  'www.busynoise.com/'
    get '/egg/', {}, { 'HTTP_HOST'=> domain }
    follow_redirect!
    last_response.body
    .should.match /This website has moved/
  end

  it 'shows a moving message for www.busynoise.com/egg' do 
    domain =  'www.busynoise.com'
    get '/egg', {}, { 'HTTP_HOST'=> domain }
    follow_redirect!
    follow_redirect!
    last_response.body
    .should.match /This website has moved/
  end

  it 'redirect /salud/robots.txt to /robots.txt' do
    get '/salud/robots.txt'
    follow_redirect!
    assert_equal '/robots.txt', last_request.fullpath
  end

  it 'redirect any 404 url ending in /+/ to ending /' do
    get '/missing/page/+/'
    assert_redirect "/missing/page/"
  end

  it 'redirect /templates/ to /' do
    get '/templates/'
    assert_redirect '/'
  end

end # === class Test_Control_Old_Apps_Read

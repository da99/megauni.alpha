# controls/Clubs.rb

# Originally, the Hearts Club used to be it's own
# website at: SurferHearts.com
# This test makes sure it handles the old urls
# when SurferHearts.com redirects to the Hearts Club
# on MegaUni.com
describe :Control_Surfer_Hearts_Read do

  it 'renders page w/ assets: /heart_link/{id}/' do
    get '/heart_link/10/'
    should_render
  end

  it 'redirects /mess/{id}/ with ids under 200 to /heart_link/{id}/' do
    [1, 10, 143].each { |id|
      get "/mess/#{id}/"
      assert_redirect "/heart_link/#{id}/", 301
    }
  end
  
  it 'redirects /hearts/m/ to /blog/' do 
    get '/hearts/m/'
    assert_redirect '/blog/'
  end
  
  it 'renders page w/assets: /blog/' do
    get '/blog/'
    should_render
  end

  it 'redirects /uni/hearts/ to /blog/' do 
    get '/uni/hearts/'
    assert_redirect '/blog/'
  end

  it 'redirects /uni/hearts/by_date/2007/8/ to /blog/2007/8/. ' do
    get '/uni/hearts/by_date/2007/8/'
    follow_redirect!
    assert_equal '/blog/2007/8/', last_request.fullpath
  end

  it 'redirects /clubs/hearts/by_label/stuff_for_dudes/ => /heart_links/by_category/14/' do
    get "/clubs/hearts/by_label/stuff_for_dudes/"
    redirects_to 301, "/heart_links/by_category/14/"
  end

  it 'redirects /uni/hearts/by_label/stuff_for_dudes/ => /heart_links/by_category/14/' do
    get '/uni/hearts/by_label/stuff_for_dudes/'
    assert_redirect '/heart_links/by_category/14/'
  end

  it 'responds with 404 for a heart link that does not exist.' do
    get "/heart_link/1000000/"
    last_response.status.should == 404
    # assert_match( /Document not found for Message id: .1000000./, err.message )
  end

  it 'redirects "/rss/" to "/rss.xml".' do
    get '/rss/'
    follow_redirect!
    assert_equal '/rss.xml', last_request.fullpath 
  end

  (14..22).to_a.each { |id|

    prefix = "/heart_links/by_category/#{id}"
    
    it "renders page w/assets: #{prefix}/" do
      get "#{prefix}/"
      should_render
    end
    
    it "redirects #{prefix}.html to .../#{id}/" do
      get "#{prefix}.html"
      assert_redirect "#{prefix}/", 301
    end
    
  }

  %w{ /hearts/by_date /uni/hearts/by_date /heart_links/by_date }.each { |pre|
    it "redirects #{pre}/2007/01/ to /blog/2007/01/" do
      get "#{pre}/2007/01/"
      assert_redirect "/blog/2007/01/"
    end
  }

  it "renders page w/ assets: /blog/2007/1/" do
    get "/blog/2007/1/"
    should_render
  end
  
  %w{ 1 2 3 4 8 }.each { |id|
    it "renders /blog/2007/#{id}/" do
      get "/blog/2007/#{id}/"
      should_render
    end
  }

  it "redirects /blog/2007/ to /blog/" do
    get "/blog/2007/" 
    assert_redirect "/blog/"
  end

  it "renders /blog/" do
    get "/blog/" 
    should_render
  end

  %w{ /club/hearts/ /uni/hearts/ /hearts/ }.each { |url|
    it "redirects #{url} to /blog/" do
      get url
      assert_redirect '/blog/'
    end
  }

  it "redirects /about.html to /about/" do
    get "/about.html"
    assert_redirect "/about/"
  end

  it 'renders /about/' do
    get "/about/"
    should_render
  end
  
  it 'redirects /uni/hearts/magazine/ to /blog/2007/1/' do
    get '/uni/hearts/magazine/'
    should_redirect "/blog/2007/1/"
  end

  it 'redirects /[rand]/surfboard-usb-drives/ to ' do
    get "/#{rand 1000}surfboard-usb-drives/"
    redirects_to PERM, '/heart_link/57/'
  end

  it_redirects TEMP, "/heart_links/by_category/new/", "/blog/"
  
  it_redirects TEMP, "/uni/hearts/qa/", "/blog/"

  %w{ 1 2 3 4 8 }.each { |mo|
    it_redirects PERM, "/news/by_date/2007/#{mo}/", "/blog/2007/#{mo}/"
    it_redirects PERM, "/clubs/hearts/by_date/2007/#{mo}/", "/blog/2007/#{mo}/"
  }

  it 'redirect /skins/jinx/css/main_show.css to /stylesheets/en-us/Hellos_list.css' do
    get '/skins/jinx/css/main_show.css'
    follow_redirect!
    assert_equal "/stylesheets/en-us/Hellos_list.css", last_request.fullpath
  end

  it 'redirect /skins/jinx/css/news_show.css to /stylesheets/en-us/Hellos_list.css' do
    get '/skins/jinx/css/news_show.css'
    follow_redirect!
    assert_equal "/stylesheets/en-us/Hellos_list.css", last_request.fullpath
  end


end # === class Test_Control_Club_Hearts_Read

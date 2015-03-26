# controls/Clubs.rb

describe "Old Pages:" do

  # === timers ==========================================

  it 'redirect /timer to /busy-noise' do
    get '/timer'
    redirects_to '/busy-noise'
  end

  it 'redirect /myeggtimer%5C to /myeggtimer' do
    get '/myeggtimer%5C'
    redirects_to "/myeggtimer"
  end

  # === heroku-mongo ====================================

  it "renders /salud" do
    get "/salud"
    last_response.status.should == 200
    html.should.match /Jabon/
  end

  %w{
      meno-osteo back-pain
      mike-in-tokyo-rogers
      liberty
      arthritis back-pain cancer child-care computer dementia
      depression flu hair health heart hiv housing
      preggers 
  }.uniq.each { |name|
    it_redirects PERM, "/uni/#{name}",    "/#{name}"
    it_redirects PERM, "/clubs/#{name}",  "/#{name}"

    it "renders /#{name}" do
      get "/#{name}"
      last_response.status.should == 200
    end
  }

  %w{ back-pain meno-osteo }.each { |right|
    wrong = right.sub('-', '_')

    it "redirects /#{wrong} to /#{right}" do
      get "/#{wrong}"
      follow_redirect!
      last_request.path_info.should == "/#{right}"
      last_response.status.should == 200
    end
  }

  it 'redirects /child_care/clubs/child_care to /child-care' do
    get '/child_care/clubs/child_care'
    http_code.should == 301
    redirect_url.should == '/child-care'
  end

  it 'redirect /back_pain/clubs/back_pain to /back-pain' do
    get '/back_pain/clubs/back_pain'
    http_code.should == 301
    redirect_url.should == '/back-pain'
  end

  # ================ Club Search ===========================

  it "redirects /uni to /" do
    get '/uni'
    http_code.should == 301
    redirect_url.should == '/'
  end

  it "redirects /search to /" do
    get "/search"
    http_code.should == 301
    redirect_url.should == '/'
  end

  it "redirects /club-search to /" do
    get "/club-search"
    redirect_url.should == '/'
  end

end # === class Test_Control_Clubs_Read



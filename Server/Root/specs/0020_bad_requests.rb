# controls/Bad_Requests.rb


describe :Control_Bad_Requests do

  it 'redirect any favicon.ico requests to /favicon.ico' do
    get "/my-egg-timer/favicon.ico"
    redirect_url.should == "/favicon.ico"
  end

  it 'redirect /SWF/main.swf to http://www.bing.com/SWF/main.swf' do
    get "/SWF/main.swf"
    redirect_url.should == "http://www.bing.com/SWF/main.swf"
  end

  it 'redirect /(null)/ to http://www.bing.com/(null)/' do
    get "/(null)/"
    http_code.should == 400
  end

  it "redirects w/ 301: /manager/status -> http://www.honoringhomer.net/" do
    get "/manager/status"
    redirects_to "http://www.honoringhomer.net/"
  end

  it "redirects w/#{PERM} /admin/spaw/spacer.gif -> #{BING_URL}" do
    get "/admin/spaw/spacer.gif"
    redirects_to PERM, BING_URL
  end

end # === class Test_Control_Bad_Requests

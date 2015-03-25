# middleware/Mu_Archive_Redirect.rb


describe :Control_Bad_Agents do

  it "redirect any path ending with .php to #{BING_URL}" do
    get '/get_orders_list.php'
    redirects_to BING_URL
  end

  it "redirect any deep path (/.+/.+/index.php) to #{BING_URL}" do
    get '/Site_old/administrator/index.php'
    redirects_to BING_URL
  end

  it "redirect any path ending with .asp to #{BING_URL}" do
    get '/downloads/search.asp'
    redirects_to BING_URL
  end

  it "redirect any user agent containing 'panscient' to #{BING_URL}" do
    header 'USER_AGENT', 'panscient.com'
    get '/'
    redirects_to BING_URL
  end

  it( 'redirect any user agent containing "Yahoo! Slurp/" and ' +
       'looking for path start with /SlurpConfirm404' ) do

    header 'USER_AGENT', 'Mozilla/5.0 (compatible; Yahoo! Slurp/3.0; http://help.yahoo.com/help/us/ysearch/slurp)'
    get '/SlurpConfirm404/drodgers.htm'

    redirects_to BING_URL
  end

  it "redirect to #{BING_URL} if user agent is TwengaBot-Discover and page is missing" do
    ua = 'TwengaBot-Discover (http://www.twenga.fr/bot-discover.html)'
    header 'USER_AGENT', ua
    get '/some/missin/page'
    redirects_to PERM, BING_URL
  end

  it "redirect to #{BING_URL} if Sosospider and file is CSS" do
    header 'USER_AGENT', "Sosospider+(+http://help.soso.com/webspider.htm)"
    get "/stylesheets/en-us/hellos_list.css"
    redirects_to BING_URL
  end

  it "redirects all user agents ' F.cking ' to #{BING_URL}" do
    header 'USER_AGENT', "Morfeus Fucking Scanner"
    get "/"
    redirects_to 301, BING_URL
  end

  it "redirects user agent 'ZmEu' to bing site" do
    header 'USER_AGENT', 'ZmEu'
    get "/"
    redirects_to 301, BING_URL
  end

end # === class Test_Control_Old_Apps_Read

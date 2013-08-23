get "/" do
  if !request[:user]
    return html 'App/top_slash', {
      :title => 'OkDoki.com',
      :YEAR  => Time.now.year
    }
  end

  opts = { :user => req.user, :Bots => {:Own => [], :Use => []} }

  html 'Customer/lifes', {
    :title => "My Okdoki",
    :Bots  => { :Own => f.data.Bots.Own, :Use => f.data.Bots.Use }
  }
end # === get /

get "/unauthenticated" do
  "Not logged in"
end


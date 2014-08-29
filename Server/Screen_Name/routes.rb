

# =====================================================
# Create
# =====================================================

post '/@' do
  begin
    sn   = user.create(:screen_name, params[:screen_name])
    json true, "Your new life has been created: #{sn.screen_name}" , sn.to_public
  rescue Okdoki::Invalid => e
    puts e.msg, "--"
    json false, e.msg
  end
end # === post

post "/@:screen_name/code" do

  begin
    USER().screen_name(params[:screen_name]).upsert(:code=>params[:code])
  rescue Code::Invalid =>e
    json false, e.msg
  end

end # === post /Code

# =====================================================
# Read
# =====================================================

get '/@:screen_name' do
  sn = Screen_Name.canonize params[:screen_name]

  # === Standardize the username.
  if sn != params[:screen_name]
    return redirect(to('/@' + sn), 302)
  end

  # === Grab/send info.
  begin
    life = Screen_Name.read_by_screen_name(sn)
    html 'Screen_Name/me', {
      :title       => "The life of #{life.screen_name}",
      :screen_name => life.screen_name,
      :is_owner    => logged_in? && user.is?(life)
    }
  rescue Screen_Name::Not_Found => e
    pass
  end

end # === get /@:screen_name

get "/@:screen_name/code" do

  begin
    Code.read(params)
  rescue Code::Not_Found =>e
    json false, e.msg
  end

end # === get /Code/:id




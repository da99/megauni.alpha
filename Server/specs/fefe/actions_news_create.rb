  context 'News :create (action)' 
  
  before do
    @path = '/news/'
    @new_values = { :title=>'Vitamin D3 Shop', 
                  :teaser=>'The Teaser',
                  :body=>'New Openining' }
    @path_args = [ @path, @new_values, ssl_hash ]
  end

  it 'does not allow strangers' do
    post *@path_args
    demand_regex_match( 
                      /Not logged in. Log-in first and try again/ ,
                      last_response.body
                      )
  end

  it 'does not allow members' do
    log_in_member
    post *@path_args
    demand_equal 404, last_response.status
  end

  it 'allows admins' do
    log_in_admin
    post *@path_args
    follow_ssl_redirect!
    demand_equal 200, last_response.status
    demand_regex_match /^\/news\/[A-Za-z0-9]{6,32}\// , last_request.fullpath
    demand_regex_match  /#{Regexp.escape(@new_values[:title])}/, last_response.body 
    demand_regex_match /#{Regexp.escape(@new_values[:body])}/, last_response.body
  end

  it 'redirects to :new and shows error messages' do
    log_in_admin
    post @path, {}, ssl_hash
    follow_ssl_redirect!
    demand_regex_match /Title is required/, last_response.body 
    demand_regex_match /Body is required/, last_response.body
  end

end # ===


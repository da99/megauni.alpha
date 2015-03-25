# controls/Members.rb
require 'tests/__rack_helper__'

class Test_Control_Members_Create < Test::Unit::TestCase

  must 'redirects and shows password errors' do 
    post '/member/', {:add_life=>'friend', :add_life_username=>'da01111' + rand(10000).to_s, :password=>'pw'}, ssl_hash
    follow_redirect!
    assert_match(/Password must be at least 5 characters long/, last_response.body)
  end

  must 'redirects and shows username errors' do
    post '/member/', {:add_life=>'friend', :add_life_username=>'d', :password=>'myuni4vr', :confirm_password=>'myuni4vr'}, ssl_hash
    follow_redirect!
    assert_match(
      /Username is too small. It must be at least 2 characters long/, 
      last_response.body 
    )
  end

  must 'redirects and shows username uniqueness errors' do
    vals = { :password=>'myuni4vr', 
             :confirm_password=>'myuni4vr', 
             :add_username=>'admin-member-1'}
    post '/member/', vals, ssl_hash
    follow_redirect!
    assert_match( /Username, admin\-member\-1, already taken/, last_response.body )
  end

  must( 'does not create itself + username if username is already taken.' ) do
    
    u_name = "da01-#{Time.now.to_i}"
    total_rows = lambda { Member.db.collection.find().count }
    old = total_rows.call
    assert_raise(Member::Invalid) do
      Member.create(nil, { 
          :password=>'test123test',
          :confirm_password => 'test123test',
          :add_username => regular_username(1)
      })
    end
    
    assert_equal old, total_rows.call
    
  end
  
  must 'show form with :add_username' do
    get "/create-account/"
    input = Nokogiri::HTML(last_response.body).css('form#form_member_create input[name=add_username]').first
    assert input
  end

end # === class Test_Control_Members_Create

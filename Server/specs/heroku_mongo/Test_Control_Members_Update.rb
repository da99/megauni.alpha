# controls/Members.rb
require 'tests/__rack_helper__'
require 'helpers/Pony'

class Test_Control_Members_Update < Test::Unit::TestCase

  must 'allow the addition of a new username' do
    rand_un = "new_username_#{rand(10000)}"
    log_in_regular_member(3)
    put "/member/", :add_username=>rand_un
    reg3 = Member.by_id(regular_member(3).data._id)
    assert reg3.lifes.usernames.include?(rand_un)
  end

  must 'redirect to new username after insertion' do
    rand_un = "new_username_#{rand(20000)}"
    log_in_regular_member(3)
    put "/member/", :add_username=>rand_un
    follow_redirect!
    assert_equal "/life/#{rand_un}/", last_request.fullpath
  end

  must 'send email to Member if password is reset' do
    Pony.expects(:mail).returns(true)
    mem = create_member
    post "/reset-password/", :email=>mem.data.email
  end

  must 'reset password if Member enters valid email' do
    Pony.expects(:mail).returns(true)
    mem = create_member
    post "/reset-password/", :email=>mem.data.email
    assert_equal true, mem.password_in_reset?
  end

  must 'send an email with a URL to change password' do
    mem = create_member
    Pony.expects(:mail).returns(true).with { |hsh|
      hsh[:body]['/change-password/']
    }
    post "/reset-password/", :email=>mem.data.email
    assert_equal true, mem.password_in_reset?
  end

  must 'allow multiple password resets' do
    mem = create_member
    
    3.times do |i|
      Pony.expects(:mail).returns(true)
      post "/reset-password/", :email=>mem.data.email
      assert_equal true, mem.password_in_reset?
    end
  end

  must 'present a message account not found' do
    email = "tests@something.com"
    post '/reset-password/', :email=>email
    assert last_response.body["No account found with email: #{email}"]
  end

  must 'redirect to /log-in/ after password is changed through reset.' do
    mem = create_member
    new_pswd = 'random1245'
    code = mem.reset_password
    post "/change-password/#{code}/#{mem.data.email}/", :password=>new_pswd, :confirm_password=>new_pswd
    follow_redirect!
    assert_equal "/log-in/", last_request.path_info
  end

  must "flash message on /log-in/ confirming password has been changed." do
    mem = create_member
    new_pswd = 'random1245'
    code = mem.reset_password
    post "/change-password/#{code}/#{mem.data.email}/", :password=>new_pswd, :confirm_password=>new_pswd
    follow_redirect!
    assert last_response.body['Your password has been updated']
  end

  must 'flash message showing password and password confirmation do not match' do
    mem = create_member
    code = mem.reset_password
    post "/change-password/#{code}/#{mem.data.email}/", :password=>rand(1000).to_s, :confirm_password=>rand(100000).to_s
    follow_redirect!
    assert last_response.body['Password and password confirmation do not match.']
  end

end # === class Test_Control_Members_Update

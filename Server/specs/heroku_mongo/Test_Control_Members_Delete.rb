# controls/Members.rb
require 'tests/__rack_helper__'

class Test_Control_Members_Delete < Test::Unit::TestCase

  must 'log-out member after deletion' do
    mem = create_member_and_log_in
    delete '/delete-account-forever-and-ever/'
    assert_log_out
  end

  must 'delete member' do
    mem = create_member_and_log_in
    delete '/delete-account-forever-and-ever/'
    assert_raises(Member::Not_Found) {
      Member.by_id(mem.data._id)
    }
  end

  must 'redirect to /' do
    mem = create_member_and_log_in
    delete '/delete-account-forever-and-ever/'
    assert_redirect '/', 303
  end

  must 'show flash message on redirect to /' do
    mem = create_member_and_log_in
    delete '/delete-account-forever-and-ever/'
    follow_redirect!
    assert last_response.body['account has been deleted']
  end

end # === class Test_Control_Members_Delete

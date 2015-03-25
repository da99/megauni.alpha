# controls/Members.rb
require 'tests/__rack_helper__'

class Test_Control_Members_Edit < Test::Unit::TestCase

  must 'require log-in to added a new username' do
    get "/lifes/"
    follow_redirect!
    assert_equal "/log-in/", last_request.fullpath
  end

  must 'render for members' do
    log_in_regular_member(1)
    get "/lifes/"
    assert_equal 200, last_response.status
  end

end # === class Test_Control_Members_Edit

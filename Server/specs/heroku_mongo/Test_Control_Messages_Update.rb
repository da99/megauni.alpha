# controls/Messages.rb
require 'tests/__rack_helper__'

class Test_Control_Messages_Update < Test::Unit::TestCase
  
  must 'update if admin' do
    mess = create_message(regular_member(1))
    mess_id = mess.data._id.to_s
    new_body = 'http://new.com'
    log_in_admin
    post "/mess/#{mess_id}/", {:body=>new_body, :_method=>'put'}
    reloaded = Message.by_id(mess.data._id)

    assert_equal new_body, reloaded.data.body
  end
  
  must 'update if owner' do
    mess = create_message(regular_member(1))
    mess_id = mess.data._id.to_s
    new_body = 'http://new.com'
    log_in_regular_member(1)
    post "/mess/#{mess_id}/", {:body=>new_body, :_method=>'put'}
    reloaded = Message.by_id(mess.data._id)

    assert_equal new_body, reloaded.data.body
  end

  must 'redirect to message href after update' do
    mess = create_message(mem)
    mess_id = mess.data._id.to_s
    new_body = 'http://new.com'
    log_in_regular_member(1)
    post "/mess/#{mess_id}/", {:editor_id=>mem.lifes._ids.first, :body=>new_body, :_method=>'put'}
    assert_redirect mess.href, 303
  end

end # === class Test_Control_Messages_Update

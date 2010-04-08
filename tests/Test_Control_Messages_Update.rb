# controls/Messages.rb
require 'tests/__rack_helper__'

class Test_Control_Messages_Update < Test::Unit::TestCase

  def club
    Club.db_collection.find_one()
  end

  def create_message mem
    Message.create(
      mem, 
      :username_id=> mem.username_ids.first,
      :target_ids => [club['_id']],
      :body => 'test body',
      :emotion => 'poignant',
      :category => 'tweet',
      :privacy => 'public'
    )
  end
  
	must 'update if admin' do
    mess = create_message(regular_member_1)
		mess_id = mess.data._id.to_s
		new_body = 'http://new.com'
		log_in_admin
		post "/mess/#{mess_id}/", {:body=>new_body, :_method=>'put'}
		reloaded = Message.by_id(mess.data._id)

		assert_equal new_body, reloaded.data.body
  end
  
  must 'update if owner' do
    mess = create_message(regular_member_1)
		mess_id = mess.data._id.to_s
		new_body = 'http://new.com'
		log_in_member
		post "/mess/#{mess_id}/", {:body=>new_body, :_method=>'put'}
		reloaded = Message.by_id(mess.data._id)

		assert_equal new_body, reloaded.data.body
  end

end # === class Test_Control_Messages_Update
# models/Message.rb

class Test_Model_Message_Create < Test::Unit::TestCase

  def club
    @club ||= Club.db.collection.find_one
  end

  must 'be allowed to be created by member' do
    mem = Message.create(
      regular_member(1), {
        :owner_id => regular_member(1).lifes._ids.last,
        :message_model => 'random',
        :target_ids =>  [ club['_id'] ],
        :body => 'test body',
        :emotion => 'poignant',
        :category => 'tweet',
        :privacy => 'public'
      }
    )
    assert_equal mem.data._id, Message.by_id(mem.data._id).data._id
  end
  
  must 'require :message_model' do
    mem = regular_member(1)
    club = create_club(mem)
    err = assert_raise(Message::Invalid) {
      create_message mem, club, :message_model=>nil
    }
    assert_match( /Message model/, err.message )
  end

  must 'be created even if :target_ids is a String' do
    mem = Message.create(
      admin_member, {
        :owner_id => admin_member.lifes._ids.first,
        :message_model=>'random',
        :target_ids => club['_id'],
        :body => 'test body',
        :emotion => 'poignant',
        :category => 'tweet',
        :privacy => 'public'
      }
    )
    assert_equal mem.data._id, Message.by_id(mem.data._id).data._id
  end
  
  must 'add Club id if :parent_message_id of message is include' do
    
    mess_1 = Message.create(
      regular_member(1), {
        :owner_id => regular_member(1).lifes._ids.last,
        :body => 'test body',
        :target_ids => [club['_id']],
        :message_model => 'random',
        :privacy => 'public'
      }
    )

    mess_2 = Message.create(
      regular_member(1), {
        :owner_id => regular_member(1).lifes._ids.last,
        :body => 'test body',
        :parent_message_id => mess_1.data._id,
        :message_model => 'cheer'
      }
    )
    
    assert_equal [club['_id']], mess_2.data.target_ids
  end

  must 'ignore :target_ids in raw data if :parent_message_id is set.' do
    mess_1 = Message.create(
      regular_member(1), {
        :owner_id => regular_member(1).lifes._ids.last,
        :body => 'test body',
        :target_ids => [club['_id']],
        :message_model => 'random',
        :privacy => 'public'
      }
    )

    mess_2 = Message.create(
      regular_member(1), {
        :owner_id => regular_member(1).lifes._ids.last,
        :body => 'test body',
        :parent_message_id => mess_1.data._id,
        :target_ids => '1235',
        :message_model => 'cheer'
      }
    )
    
    assert_equal [club['_id']], mess_2.data.target_ids
  end

  must 'turn :parent_message_id from a String to a BSON::ObjectId' do
    mess_1 = Message.create(
      regular_member(1), {
        :owner_id => regular_member(1).lifes._ids.last,
        :body => 'test body',
        :target_ids => [club['_id']],
        :message_model => 'random',
        :privacy => 'public'
      }
    )

    mess_1_id = mess_1.data._id
    mess_1_id_s = mess_1_id.to_s
    mess_2 = Message.create(
      regular_member(1), {
        :owner_id => regular_member(1).lifes._ids.last,
        :body => 'test body',
        :parent_message_id => mess_1_id_s,
        :target_ids => '1235',
        :message_model => 'cheer'
      }
    )
    
    assert_equal mess_1_id, mess_2.data.parent_message_id
  end

  must 'allow replies posted to messages in life clubs' do
    mem = regular_member(1)
    un  = mem.lifes.usernames.first
    life = Life.find.username(un).go_first!
    club_id = life.data._id
    mess_1 = Message.create(
      regular_member(1), {
        :owner_id => regular_member(1).lifes._ids.last,
        :body => 'test body',
        :target_ids => [club_id],
        :message_model => 'random',
        :privacy => 'public'
      }
    )

    mess_2 = Message.create(
      regular_member(1), {
        :owner_id => regular_member(1).lifes._ids.last,
        :body => 'test body',
        :parent_message_id => mess_1.data._id,
        :target_ids => '1235',
        :message_model => 'cheer'
      }
    )
    
    assert_equal [club_id], mess_2.data.target_ids
  end

end # === class Test_Model_Message_Create

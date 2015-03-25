# models/Message.rb

class Test_Model_Message_Update < Test::Unit::TestCase

  must 'create a document log filled with changes' do
    mess   = create_message(mem, nil, :title =>'old title')
    update = Message.update(mess.data._id, mem, :title =>'new title', :editor_id => mem.lifes._ids.first )
    log    = Doc_Log.by_doc_id(mess.data._id)
    target = [["old", "new"], "title"]
    assert_equal target, log.data.diff['title']
  end

end # === class Test_Model_Message_Update

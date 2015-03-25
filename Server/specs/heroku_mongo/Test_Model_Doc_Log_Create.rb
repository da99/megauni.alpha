# models/Doc_Log.rb

require 'models/Doc_Log'

class Test_Model_Doc_Log_Create < Test::Unit::TestCase

  def mem
    regular_member(1)
  end

  def vals
    @vals_hash ||= begin
                     v = {}
                     v['old_doc'] = {'title'=>'old title'}
                     v['new_doc'] = {'title'=>'new title'}
                     v
                   end
  end
  
  must 'set :diff to a document diff' do
    vals['doc_id']  = BSON::ObjectId.new
    vals['editor_id'] = mem.lifes._ids.first
    target = {"title"=>[["old", "new"], "title"]}
    log = Doc_Log.create(mem, vals)
    assert_equal target, log.data.diff
  end

  must 'require :editor_id to be a :username_id of the :editor' do
    vals['editor_id'] = BSON::ObjectId.new
    assert_raises_with_message(Doc_Log::Invalid, /Editor id is invalid/) {
      Doc_Log.create(mem, vals)
    }
  end
  
  must 'require :doc_id to be a valid BSON::ObjectId' do
    vals['editor_id'] = mem.lifes._ids.first
    vals['doc_id'] = 'sometjing'
    assert_raises_with_message(Doc_Log::Invalid, /Doc id is not a valid id/) {
      Doc_Log.create(mem, vals)
    }
  end
   
end # === class Test_Model_Doc_Log_Create

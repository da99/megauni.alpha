
require './tests/helpers'
require './Server/Chit_Chat/model'

include Screen_Name::Test

def days_ago days
  Sequel.lit(Ok::Model::PG::UTC_NOW_RAW + " - interval '#{days * 24} hours'")
end

def update_last_read_at sn, days
  Chit_Chat::TABLE_LAST_READ.
    where(sn_id: sn.id).
    update(last_read_at: days_ago(days))
end

def update_created_at msg, days
  Chit_Chat::TABLE.
    where(id: msg.id).
    update(created_at: days_ago(days))
end

5.times do |i|
  o = create
  s = o[:sn]
  Object.const_set :"O#{i+1}", o
  Object.const_set :"S#{i+1}", s
end

describe "Chit_Chat: read_inbox" do

  before do
    Chit_Chat::TABLE.delete
    Chit_Chat::TABLE_TO.delete
    Chit_Chat::TABLE_LAST_READ.delete
    I_Know_Them::TABLE.delete
  end

  it "grabs an array of Chit_Chats from people they follow" do
    S1.create :i_know_them, S2
    S1.create :i_know_them, S3
    S2.create :chit_chat, "msg 1"
    S3.create :chit_chat, "msg 2"

    list = S1.read :chit_chat_inbox

    assert :==, ["msg 1", "msg 2"], list.map(&:body).sort
  end

  it "does not grab from people they don't follow" do
    S1.create :i_know_them, S2
    S1.create :i_know_them, S3
    S2.create :chit_chat, "msg 1"
    S3.create :chit_chat, "msg 2"
    S4.create :chit_chat, "msg 3"

    list = S1.read :chit_chat_inbox

    assert :==, ["msg 1", "msg 2"], list.map(&:body).sort
  end

  it "grabs msgs in reverse :created_at" do
    S1.create :i_know_them, S2
    S1.create :i_know_them, S3
    S2.create :chit_chat, "msg 1"
    S3.create :chit_chat, "msg 2"
    S4.create :chit_chat, "msg 3"

    list = S1.read :chit_chat_inbox

    assert :==, ["msg 2", "msg 1"], list.map(&:body)
  end

  it "grabs only the latest message from each author" do
    S1.create :i_know_them, S2
    S1.create :i_know_them, S3

    S2.create :chit_chat, "msg 1"
    S2.create :chit_chat, "msg 2"

    S3.create :chit_chat, "msg 3"
    S3.create :chit_chat, "msg 4"

    S4.create :chit_chat, "msg 5"
    S5.create :chit_chat, "msg 6"

    list = S1.read :chit_chat_inbox

    assert :==, ["msg 4", "msg 2"], list.map(&:body)
  end

  it "grabs a count of other messages waiting to be read" do
    S1.create :i_know_them, S2
    S1.create :i_know_them, S3

    S2.create :chit_chat, "msg 1"
    S2.create :chit_chat, "msg 2"
    S2.create :chit_chat, "msg 3"

    S3.create :chit_chat, "msg 4"
    S3.create :chit_chat, "msg 5"

    S4.create :chit_chat, "msg 6"
    S5.create :chit_chat, "msg 7"

    list = S1.read :chit_chat_inbox

    assert :==, [1, 2], list.map(&:cc_count)
  end

end # === describe Chit_Chat: read ===



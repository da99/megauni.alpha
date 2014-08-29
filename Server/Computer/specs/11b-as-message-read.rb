
require './Server/Computer/model'

module Chit_Chat_Test

  include Screen_Name_Test

  def update_last_read_at sn, days
    rows = Chit_Chat::TABLE_LAST_READ.
      returning.
      where(sn_id: sn.id).
      update(last_read_at: days_ago_in_sql(days))
    if rows.empty?
      Chit_Chat::TABLE_LAST_READ.
        returning.
        insert(sn_id: sn.id, last_read_at: days_ago_in_sql(days))
    end
  end

  def update_created_at msg, days
    Chit_Chat::TABLE.
      where(id: msg.id).
      update(created_at: days_ago_in_sql(days))
  end

  def create_chit_chat author, body, days_old = nil
    c = Chit_Chat.create author, body

    if days_old
      update_created_at c, days_old
    end

    c
  end

  def delete_all_chit_chats
    Chit_Chat::TABLE.delete
  end

  Owner_1 = Screen_Name_Test.create_screen_name
  Screen_Name_1 = Owner_1[:sn]

  Owner_2 = Screen_Name_Test.create_screen_name
  Screen_Name_2 = Owner_2[:sn]

  Owner_3 = Screen_Name_Test.create_screen_name
  Screen_Name_3 = Owner_3[:sn]

end # === module Chit_Chat_Test ===

describe "Computer: as-message-read" do

  before do
    delete_all_chit_chats
    delete_all_follows

    @sn1 = Chit_Chat_Test::Screen_Name_1
    @sn2 = Chit_Chat_Test::Screen_Name_2
    @sn3 = Chit_Chat_Test::Screen_Name_3

    update_screen_name_privacy @sn1, :public
    update_screen_name_privacy @sn2, :public
    update_screen_name_privacy @sn3, :public
  end

  it "reads comment count for each message"

  it "grabs an array of Chit_Chats from people they follow" do
    create_follow @sn1, @sn2
    create_follow @sn1, @sn3
    create_chit_chat @sn2, "msg 1"
    create_chit_chat @sn3, "msg 2"

    list = Chit_Chat.read_inbox @sn1

    pluck(list, :count_new)
    .should == [1, 1]
  end

  it "does not grab from people they don't follow" do
    create_follow @sn1, @sn2

    create_chit_chat @sn2, "msg 1"
    create_chit_chat @sn3, "msg 2"

    list = Chit_Chat.read_inbox @sn1

    pluck(list, :count_new)
    .should == [1]
  end

  it "does not grab messages from private screen names, no authorization" do
    create_follow @sn1, @sn2
    create_chit_chat @sn2, "msg 1"
    update_screen_name_privacy @sn2, :private

    list = Chit_Chat.read_inbox @sn1
    list.size.should == 0
  end

  it "grabs follows in reverse :created_at" do
    create_follow @sn1, @sn2
    create_follow @sn1, @sn3
    Follow::TABLE.update(:created_at=> days_ago_in_sql(3))

    create_chit_chat @sn2, "msg 1", 1
    create_chit_chat @sn2, "msg 2", 1
    create_chit_chat @sn3, "msg 3"

    list = Chit_Chat.read_inbox @sn1

    pluck(list, :count_new)
    .should == [1, 2]
  end

  it "does not count older msgs than :last_read_at" do
    create_follow @sn1, @sn2
    create_follow @sn1, @sn3

    create_chit_chat @sn2, "msg 1 day", 1
    create_chit_chat @sn3, "msg 2 day", 2

    create_chit_chat @sn2, "msg 1"
    create_chit_chat @sn2, "msg 2"
    create_chit_chat @sn3, "msg 3"
    create_chit_chat @sn3, "msg 4"

    list = Chit_Chat.read_inbox @sn1

    pluck(list, :count_new)
    .should == [2, 2]
  end


end # === describe Computer: as-message-read ===



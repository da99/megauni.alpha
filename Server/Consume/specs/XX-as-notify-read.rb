
require './Server/Consume/model'

describe "Consume: as-notify-read read_inbox" do

  before do
    Notify::TABLE.delete
    @sn1 = Screen_Name_Test.screen_name 0
    @sn2 = Screen_Name_Test.screen_name 1
    @sn3 = Screen_Name_Test.screen_name 2
    @sn4 = Screen_Name_Test.screen_name 3
  end

  it "retrieves messages in DESC :created_at" do
    n1 = Notify.create_or_update @sn1, @sn4, "body 1"
    n2 = Notify.create_or_update @sn2, @sn4, "body 2"
    n3 = Notify.create_or_update @sn3, @sn4, "body 3"

    msgs = Notify.read_inbox @sn4
    msgs.map(&:id).should == [n3.id, n2.id, n1.id]
  end

  it "retrieves messages in DESC :update_at" do
    n1 = Notify.create_or_update @sn1, @sn4, "body 1"
    n2 = Notify.create_or_update @sn2, @sn4, "body 2"
    n3 = Notify.create_or_update @sn3, @sn4, "body 3"

    n3 = Notify.create_or_update @sn3, @sn4, "body 3"
    n1 = Notify.create_or_update @sn1, @sn4, "body 1"
    n2 = Notify.create_or_update @sn2, @sn4, "body 2"

    msgs = Notify.read_inbox @sn4
    msgs.map(&:id).should == [n2.id, n1.id, n3.id]
  end

  it "does not retrieve messages meant for others" do
    n1 = Notify.create_or_update @sn1, @sn4, "body 1"
    n2 = Notify.create_or_update @sn2, @sn4, "body 2"
    n3 = Notify.create_or_update @sn1, @sn3, "body 3"

    msgs = Notify.read_inbox @sn4
    msgs.map(&:id).should == [n2.id, n1.id]
  end

  it "does not retrieve messages where :updated_at <= :last_read_at" do
    Notify.create_or_update @sn1, @sn4, "body 1"
    Notify.create_or_update @sn2, @sn4, "body 2"
    Notify::TABLE.update(:updated_at=>Sequel.lit("timezone('UTC'::text, now())"))
    Notify::TABLE.update(:last_read_at=>Sequel.lit("timezone('UTC'::text, now())"))
    n3 = Notify.create_or_update @sn3, @sn4, "body 3"

    msgs = Notify.read_inbox @sn4
    msgs.map(&:id).should == [n3.id]
  end

  it "retrieve messages where :updated_at > :last_read_at" do
    n1 = Notify.create_or_update @sn1, @sn4, "body 1"
    n2 = Notify.create_or_update @sn2, @sn4, "body 2"
    n3 = Notify.create_or_update @sn3, @sn4, "body 3"
    Notify::TABLE.update(:last_read_at=>Sequel.lit("timezone('UTC'::text, now())"))
    Notify::TABLE.update(:updated_at=>Sequel.lit("timezone('UTC'::text, now())"))

    msgs = Notify.read_inbox @sn4
    msgs.map(&:id).should == [n3.id, n2.id, n1.id]
  end

end # === describe Consume: as-notify-read ===



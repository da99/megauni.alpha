
require './Server/Consume/model'

describe "Consume: as-permission-create" do

  before do
    @sn1 = Screen_Name_Test.screen_name 0
    @sn2 = Screen_Name_Test.screen_name 1
  end

  it "raises Invalid if permission has same to/from"

  it "adds a record with pub_class_id = 1 for life" do
    Permission.create @sn1, @sn1, @sn2

    rows = Permission::TABLE.where(
      :from_id     => @sn1.data[:id],
      :pub_class_id => Permission::Screen_Name_Class_Id,
      :pub_id      => @sn1.data[:id],
      :to_id       => @sn2.data[:id]
    ).all

    rows.size
    .should == 1
  end

  it "ignores if record already exists." do
    Permission.create @sn1, @sn1, @sn2

    rows = Permission::TABLE.where(
      :from_id     => @sn1.data[:id],
      :pub_class_id => Permission::Screen_Name_Class_Id,
      :pub_id      => @sn1.data[:id],
      :to_id       => @sn2.data[:id]
    ).all

    rows.size
    .should == 1
  end

  it "raises an error if different screen names, but same owner." do
    o   = create_screen_name
    c   = o[:c]
    sn1 = o[:sn]
    sn2 = create_screen_name(c)[:sn]

    lambda {
      Permission.create sn1, sn1, sn2
    }
    .should.raise(Permission::Invalid).message
    .should.match(/Permission can't be set for same person: #{sn1.screen_name}, #{sn2.screen_name}/)
  end


end # === describe Consume: as-permission-create ===



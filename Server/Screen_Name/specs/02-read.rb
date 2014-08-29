
include Screen_Name_Test


describe "Screen_Name.read" do

  it "returns array of Screen_Name objects when first/only arg is a Customer" do
    o = create_screen_name
    c = o[:c]
    arr = Screen_Name.read(c).map(&:screen_name).sort
    target = Screen_Name::TABLE.where(:owner_id=>c.id).all.map { |r| r[:screen_name] }.sort
    arr.should == target
  end

end # === describe Screen_Name.read ===

describe "Screen_Name :is? screen_name" do

  it "returns true if screen names have the same 'data[:screen_name]'" do
    Screen_Name_Test.screen_name(1).is?(Screen_Name_Test.screen_name 1)
    .should == true
  end

  it "returns true if screen names have the same 'data[:owner_id]'" do
    o   = create_screen_name
    c   = o[:c]
    sn1 = o[:sn]
    sn2 = create_screen_name(c)[:sn]

    sn1.is?(sn2)
    .should == true
  end

end # === describe Screen_Name :is? screen_name ===






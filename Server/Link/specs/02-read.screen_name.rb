
describe 'Link.read screen_name' do

  it "allows: STRANGER -> Screen_Name World Public" do
    WORLD!

    link = Link.read(:SCREEN_NAME, nil, sn.o.data[:screen_name])
    link.data[:screen_name].should == sn.o.data[:screen_name]
  end

  it "does not allow: Customer -> Screen_Name World Public, Blocked" do
    sn.is :WORLD
    sn.blocks meanie

    catch(:not_found) {
      meanie.reads(:SCREEN_NAME).of(sn.data[:screen_name])
    }.should == {:type=>:SCREEN_NAME, :id=>sn.data[:screen_name]}
  end # === it does not allow: STRANGER -> Screen_Name World Public, Blocked

  it "allows: Customer -> Screen_Name PROTECTED, Allowed" do
    sn.is :PROTECTED
    friend.is_allowed_to_read(sn)

    friend.reads(:SCREEN_NAME).of(sn.data[:screen_name]).id.should == sn.id
  end # === it allows: Customer -> Screen_Name Protected, Allowed

  it "allows: OWNER -> Screen_Name PROTECTED" do
    sn.is :protected

    sn.reads(:SCREEN_NAME).of(sn.data[:screen_name]).id.should == sn.id
  end # === it allows: OWNER -> Screen_Name PROTECTED

end # === describe 'Link.read screen_name'

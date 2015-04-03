
describe 'Link.read screen_name' do

  it "allows: STRANGER -> Screen_Name World Public" do
    WORLD!

    stranger.reads(:screen_name).of(sn).
      screen_name.should == sn.screen_name
  end

  it "does not allow: Customer -> Screen_Name World Public, Blocked" do
    sn.is :WORLD
    sn.blocks meanie

    catch(:not_found) {
      meanie.reads(:SCREEN_NAME).of(sn.screen_name)
    }.should == {:type=>:SCREEN_NAME, :id=>sn.screen_name}
  end # === it does not allow: STRANGER -> Screen_Name World Public, Blocked

  it "allows: Customer -> Screen_Name PROTECTED, Allowed" do
    sn.is :PROTECTED
    friend.is_allowed_to_read(sn)

    friend.reads(:SCREEN_NAME).of(sn).id.should == sn.id
  end # === it allows: Customer -> Screen_Name Protected, Allowed

  it "allows: OWNER -> Screen_Name PROTECTED" do
    sn.is :protected

    sn.reads(:SCREEN_NAME).of(sn).id.should == sn.id
  end # === it allows: OWNER -> Screen_Name PROTECTED

  it "does not show PRIVATE screen name to ALLOWed people" do
    sn.allows friend
    sn.is :PRIVATE

    catch(:not_found) {
      friend.reads(:SCREEN_NAME).of(sn)
    }.should == {:type=>:SCREEN_NAME, :id=>sn.screen_name}
  end

end # === describe 'Link.read screen_name'

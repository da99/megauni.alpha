
describe 'Link.read screen_name' do

  it "allows: STRANGER -> Screen_Name World Public" do
    sn = Screen_Name.create screen_name: "world_#{rand(1000)}"
    Screen_Name.update id: sn.data[:id], privacy: Screen_Name::WORLD

    link = Link.read(audience_id: nil, target_id: sn.id, type_id: Link::READ_SCREEN_NAME)

    link.id.should == sn.id
  end

  it "does not allow: Customer -> Screen_Name World Public, Blocked" do
    meanie = Screen_Name.create screen_name: "mean_#{rand(1000)}"
    sn = Screen_Name.create screen_name: "blocked_#{rand(10000)}"
    Screen_Name.update id: sn.id, privacy: Screen_Name::WORLD
    Link.create owner_id: sn.data[:owner_id], type_id: Link::BLOCK_ACCESS_SCREEN_NAME, left_id: meanie.id, right_id: sn.id

    read = {audience_id: meanie.data[:owner_id], target_id: sn.id, type_id: Link::READ_SCREEN_NAME}
    catch(:not_found) {
      Link.read read
    }.should == read

  end # === it does not allow: STRANGER -> Screen_Name World Public, Blocked

  it "allows: Customer -> Screen_Name PROTECTED, Allowed" do
    friend = Screen_Name.create screen_name: "pheobe_#{rand(10000)}"
    sn = Screen_Name.create screen_name: "allow_#{rand(1000)}"
    Screen_Name.update id: sn.id, privacy: Screen_Name::PROTECTED
    friend.is_allowed_to_read(sn)

    Link.read(Link::READ_SCREEN_NAME, friend.data[:owner_id], sn.id ).id.should == sn.id
  end # === it allows: Customer -> Screen_Name Protected, Allowed

  it "allows: OWNER -> Screen_Name PROTECTED" do
    sn = Screen_Name.rand("pro")
    Screen_Name.update id: sn.id, privacy: Screen_Name::PROTECTED

    Link.read(:READ_SCREEN_NAME, sn.data[:owner_id], sn.id).id.should == sn.id

  end # === it allows: OWNER -> Screen_Name PROTECTED

end # === describe 'Link.read screen_name'

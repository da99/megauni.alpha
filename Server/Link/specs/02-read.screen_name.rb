
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
    Screen_Name.update id: sn.data[:id], privacy: Screen_Name::WORLD
    Link.create owner_id: sn.data[:owner_id], type_id: Link::BLOCK, left_id: sn.id, right_id: meanie.id

    read = {audience_id: meanie.data[:owner_id], target_id: sn.id, type_id: Link::READ_SCREEN_NAME}
    catch(:not_found) {
      Link.read read
    }.should == read

  end # === it does not allow: STRANGER -> Screen_Name World Public, Blocked

  it "allows: Customer -> Screen_Name Protected, Allowed" do
    friend = Screen_Name.create screen_name: "pheobe_#{rand(10000)}"
    sn = Screen_Name.create screen_name: "allow_#{rand(1000)}"
    Screen_Name.update id: sn.data[:id], privacy: Screen_Name::PROTECTED
    Link.create owner_id: sn.data[:owner_id], type_id: Link::ALLOW, left_id: sn.id, right_id: friend.id

    Link.read(audience_id: friend.data[:owner_id], target_id: sn.id, type_id: Link::READ_SCREEN_NAME).id.should == sn.id
  end # === it allows: Customer -> Screen_Name Protected, Allowed

end # === describe 'Link.read screen_name'

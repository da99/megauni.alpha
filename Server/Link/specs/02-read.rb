
describe 'Link.read' do

  it "allows: STRANGER -> Screen_Name World Public" do
    sn = Screen_Name.create screen_name: "sn_#{rand(1000)}"
    Screen_Name.update id: sn.data[:id], privacy: Screen_Name::WORLD

    link = Link.read(audience_id: nil, target_id: sn.id, type_id: Link::READ_SCREEN_NAME)

    link.id.should == sn.id
  end

  it "does not allow: Customer -> Screen_Name World Public, Blocked" do
    meanie = Screen_Name.create screen_name: "mean_#{rand(1000)}"
    sn = Screen_Name.create screen_name: "sn_#{rand(10000)}"
    Screen_Name.update id: sn.data[:id], privacy: Screen_Name::WORLD
    Link.create owner_id: sn.data[:owner_id], type_id: Link::BLOCK, left_id: sn.id, right_id: meanie.id

    read = {audience_id: meanie.data[:owner_id], target_id: sn.id, type_id: Link::READ_SCREEN_NAME}
    catch(:not_found) {
      Link.read read
    }.should == read

  end # === it does not allow: STRANGER -> Screen_Name World Public, Blocked

  it "allows: Customer -> Screen_Name Protected, Allowed" do
    friend = Screen_Name.create screen_name: "pheobe_#{rand(10000)}"
    sn = Screen_Name.create screen_name: "sn_#{rand(1000)}"
    Screen_Name.update id: sn.data[:id], privacy: Screen_Name::PROTECTED
    Link.create owner_id: sn.data[:owner_id], type_id: Link::ALLOW, left_id: sn.id, right_id: friend.id

    Link.read(audience_id: friend.data[:owner_id], target_id: sn.id, type_id: Link::READ_SCREEN_NAME).id.should == sn.id
  end # === it allows: Customer -> Screen_Name Protected, Allowed

  it "allows: STRANGER -> POST from PUBLIC SCREEN_NAME" do
    sn = Screen_Name.create(screen_name: "sn_#{rand(10000)}")
    Screen_Name.update(id: sn.data[:id], privacy: 1)
    computer = Computer.create(
      owner_id: sn.data[:id],
      code: {}
    )

    link = Link.read(
      consumer_id: nil,
      target_id:   computer.data[:id],
      type_id:     :read_computer
    )

    link[:target_id].should == computer.data[:id]
  end

  it "disallows: STRANGER -> POST from PROTECTED SCREEN_NAME" do
    sn = Screen_Name.create(screen_name: "sn_#{rand(10000)}")
    Screen_Name.update(id: sn.data[:id], privacy: 2)
    computer = Computer.create(
      owner_id: sn.data[:id],
      code: {}
    )

    link = Link.read(
      consumer_id: nil,
      target_id:   computer.data[:id],
      type_id:     :read_computer
    )

    link.should = nil
  end

  it "allows: OWNER -> POST from PRIVATE SCREEN_NAME"

  it "allows: CUSTOMER -> POST from PRIVATE SCREEN_NAME w/exceptions"

end # === describe 'Link.read'

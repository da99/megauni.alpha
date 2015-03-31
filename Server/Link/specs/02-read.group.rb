

describe 'Link.read group' do

  it "allows: STRANGER -> GROUP from WORLD Screen_Name" do
    sn = Screen_Name.create(screen_name: "group_#{rand(10000)}")
    Screen_Name.update(id: sn.id, privacy: Screen_Name::WORLD)

    computers = []
    [1,2,3].each { |n|
      computers << (c = Computer.create(owner_id: sn.id, code: {}))
      Link.create(
        owner_id: sn.data[:owner_id],
        type_id:  Link::POST_TO_SCREEN_NAME,
        left_id:  sn.id,
        right_id: c.id
      )
    }

    targets = Link.read(
      audience_id: nil,
      target_id:   sn.id,
      type_id:     Link::READ_GROUP
    )

    targets.map(&:id).sort.should == computers.map(&:id).sort
  end

  it "disallows: STRANGER -> POST from PROTECTED SCREEN_NAME" do
    sn = Screen_Name.create(screen_name: "sn_#{rand(10000)}")
    Screen_Name.update(id: sn.id, privacy: Screen_Name::PROTECTED)

    computer = Computer.create( owner_id: sn.id, code: {} )
    link     = Link.create(owner_id: sn.id, type_id: Link::POST_TO_SCREEN_NAME, left_id: sn.id, right_id: computer.id)

    catch(:not_found) {
      link = Link.read(
        consumer_id: nil,
        target_id:   sn.id,
        type_id:     Link::READ_GROUP
      )
    }.should == {:type_id=>Link::READ_SCREEN_NAME, :audience_id=>nil, :target_id=>sn.id}
  end

  it "allows: OWNER -> POST from PRIVATE SCREEN_NAME"

  it "allows: CUSTOMER -> POST from PRIVATE SCREEN_NAME w/exceptions"


end # === describe 'Link.read group'

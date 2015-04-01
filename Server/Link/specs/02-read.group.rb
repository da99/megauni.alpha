

describe 'Link.read group' do

  it "allows: STRANGER -> GROUP from WORLD Screen_Name" do
    sn = screen_name "group"
    sn.is :WORLD

    computers = []
    [1,2,3].each { |n|
      computers << (c = Computer.create(owner_id: sn.id, code: {}, privacy: Computer::WORLD))
      c.posted_to(sn, sn)
    }

    targets = Link.read(
      audience_id: nil,
      target_id:   sn.id,
      type_id:     Link::READ_GROUP
    )

    targets.map(&:id).sort.should == computers.map(&:id).sort
  end

  it "disallows: STRANGER -> POST from PROTECTED SCREEN_NAME" do
    sn = screen_name
    sn.is :PROTECTED

    computer = sn.computer( {}, :WORLD )
    link     = computer.posted_to(sn, sn) 

    catch(:not_found) {
      link = Link.read( :GROUP, nil, sn.id )
    }.should == {:type_id=>Link::READ_SCREEN_NAME, :audience_id=>nil, :target_id=>sn.id}
  end

  it "disallows: computer being listed from a BLOCKed user by Screen_Name/Owner" do
    sn      = screen_name "private"
    sn.is :WORLD

    meanie = screen_name "meanie"


    computer = sn.computer({}, :WORLD)
    computer.posted_to(sn, sn)
    meanie.is_allowed_to_link_to(sn)

    blocked  = meanie.computer({}, :WORLD)
    blocked.posted_to(sn, meanie)

    meanie.is_block_from(sn)

    Link.read(:GROUP, nil, sn.id).
      map(&:id).
      should == [computer.id]

  end # === it disallows: computer being listed from a BLOCKed user by Screen_Name/Owner

  it "disallows: Computer being listed if set to PRIVATE by owner who linked it, not SN owner." do
    sn     = screen_name "o"
    friend = screen_name "f"
    friend.is_allowed_to_link_to(sn)

    computer = Computer.create owner_id: friend.id, code: {}, privacy: Computer::WORLD
    computer.posted_to sn, friend
    Computer.update(id: computer.id, privacy: Computer::PRIVATE)

    catch(:not_found) {
      Link.read(
        audience_id: sn.data[:owner_id],
        target_id:   sn.id,
        type_id:     Link::READ_GROUP
      )
    }.should == {:audience_id=>sn.data[:owner_id], :type_id=>Link::READ_GROUP, :target_id=>sn.id}

  end # === it disallows: Private Computer being listed if set to PRIVATE by owner, not SN owner.

  it "disallows: listing computers if link is made by someone that has been removed from the ALLOW list" do
    friend = screen_name("removed")
    sn     = screen_name("remover")
    link = friend.is_allowed_to_link_to(sn)
    computer = Computer.create :owner_id=>friend.data[:owner_id], :code=>{}, :privacy=>Computer::WORLD
    computer.posted_to(sn, friend)

    DB[Link.table_name].where(id: link.id).delete
    catch(:not_found) {
      Link.read :READ_GROUP, sn.data[:owner_id], sn.id
    }.should == {:audience_id=>sn.data[:owner_id], :target_id=>sn.id, :type_id=>Link::READ_GROUP}
  end # === it

end # === describe 'Link.read group'

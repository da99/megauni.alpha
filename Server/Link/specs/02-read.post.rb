
describe 'Link.read post' do

  it "disallows: STRANGER -> POST from PROTECTED SCREEN_NAME" do
    sn.is :PROTECTED

    sn.posts({}, :WORLD)

    catch(:not_found) {
      stranger.reads(:post).of(sn, post.id)
    }.should == {:type=>:SCREEN_NAME, :id=>sn.screen_name}
  end

  it "disallows: Computer being listed if set to PRIVATE by owner who linked it, not SN owner." do
    sn     = screen_name "o"
    friend = screen_name "f"
    friend.is_allowed_to_post_to(sn)

    computer = Computer.create owner_id: friend.id, code: {}, privacy: Computer::WORLD
    computer.posted_to sn, friend
    Computer.update(id: computer.id, privacy: Computer::PRIVATE)

    catch(:not_found) {
      Link.read(
        audience_id: sn.data[:owner_id],
        target_id:   sn.id,
        type_id:     Link::READ_post
      )
    }.should == {:audience_id=>sn.data[:owner_id], :type_id=>Link::READ_post, :target_id=>sn.id}

  end # === it disallows: Private Computer being listed if set to PRIVATE by owner, not SN owner.

  it "disallows: listing computers if link is made by someone that has been removed from the ALLOW list" do
    friend = screen_name("removed")
    sn     = screen_name("remover")
    link = friend.is_allowed_to_post_to(sn)
    computer = Computer.create :owner_id=>friend.data[:owner_id], :code=>{}, :privacy=>Computer::WORLD
    computer.posted_to(sn, friend)

    DB[Link.table_name].where(id: link.id).delete
    catch(:not_found) {
      Link.read :READ_post, sn.data[:owner_id], sn.id
    }.should == {:audience_id=>sn.data[:owner_id], :target_id=>sn.id, :type_id=>Link::READ_post}
  end # === it

end # === describe 'Link.read post'


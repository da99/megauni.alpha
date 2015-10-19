
describe 'Link.read :posts' do

  it "allows: STRANGER -> post from WORLD Screen_Name" do
    WORLD!

    computers = [1,2,3].map { |n|
      sn.posts({})
    }

    stranger.reads(:posts).of(sn)
    .map(&:id).sort.should == computers.map(&:id).sort
  end

  it "disallows: STRANGER -> POST from PROTECTED SCREEN_NAME" do
    sn.is :PROTECTED

    sn.posts({}, :WORLD)
    sn.posts({}, :PROTECTED)
    sn.posts({}, :PRIVATE)

    catch(:not_found) {
      stranger.reads(:posts).of(sn)
    }.should == {:type=>:SCREEN_NAME, :id=>sn.screen_name}
  end

  it "disallows: post being listed from a BLOCKed user by Screen_Name/Owner" do
    WORLD!
    sn.posts({}, :WORLD)

    meanie.is_allowed_to_post_to(sn)
    (meanie>sn).posts({})

    meanie.is_blocked_from(sn)

    stranger.reads(:posts).of(sn).
      map(&:id).
      should == [sn.post.id]

  end # === it disallows: computer being listed from a BLOCKed user by Screen_Name/Owner

end # === describe 'Link.read :posts'


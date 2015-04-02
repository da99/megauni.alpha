

describe 'Link.read :comments' do

  it "throws :not_found if POST is marked PRIVATE" do
    WORLD!

    sn.posts({}) {
      aud.comments 'I am audience member.'
      sn.comments  'I am owner.'
      is :PRIVATE
    }

    catch(:not_found) {
      aud.reads(:COMMENTS).of(sn.post)
    }[:type].should == :READ_POST
  end

  it "does not list comments by authors BLOCKED by POST owner/screen_name" do
    WORLD!
    sn.posts({}) {
      friend.comments 'I am friend.'
      meanie.comments 'I am no-friend.'
    }

    sn.blocks meanie
    STRANGER.reads(:COMMENTS).of(sn.post).map(&:id).should == [friend.comment.id]
  end

  it "does not list comments by authors BLOCKed by AUDIENCE member" do
    WORLD!

    sn.posts({}) {
      friend.comments 'I am friend.'
      meanie.comments 'I am meanie.'
    }

    aud.blocks meanie
    aud.reads(:comments).of(sn.post).map(&:id).should == [friend.comment.id]
  end

  it "does not list comments by authors who BLOCKed the AUDIENCE member" do
    WORLD!

    sn.posts({}, :WORLD) {
      friend.comments 'I am friend.'
      meanie.comments 'I am meanie.'
    }

    friend.blocks aud
    aud.reads(:COMMENTS).of(post).map(&:id).should == [meanie.comment.id]
  end

end # === describe 'Link.read :comments'


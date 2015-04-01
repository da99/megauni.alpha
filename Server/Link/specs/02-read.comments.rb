

describe 'Link.read :comments' do

  it "throws :not_found if POST is marked PRIVATE" do
    (sn = screen_name "main").is :WORLD
    (aud = screen_name "audience").is :WORLD
    (post = sn.computer({}, :WORLD))
    aud.comments_on(post, 'I am audience member.')
    post.is :PRIVATE

    catch(:not_found) {
      Link.read(:COMMENTS, aud, post.id)
    }.should == {type: :READ_COMPUTER, id: post.id}
  end

  it "does not list comments by authors BLOCKED by POST owner/screen_name" do
    (sn = screen_name "main").is :WORLD
    (post = sn.computer({}, :WORLD)).posted_to(sn)

    f_comment = (friend = screen_name "friend").comments_on(post, 'I am friend.')
    m_comment = (meanie = screen_name "meanie").comments_on(post, 'I am no-friend.')

    sn.blocks meanie
    Link.read(:COMMENTS, nil, post.id).map(&:id).should == [f_comment.id]
  end

  it "does not list comments by authors BLOCKed by AUDIENCE member" do
    (sn     = screen_name "main").is :WORLD
    (aud    = screen_name "audience").is :WORLD
    (friend = screen_name "friend").is :WORLD
    (meanie = screen_name "meanie").is :WORLD

    post = sn.computer({}, :WORLD)
    f_comment = friend.comments_on(post, 'I am friend.')
    m_comment = meanie.comments_on(post, 'I am meanie.')

    aud.blocks meanie
    (Link.read :COMMENTS, aud, post).map(&:id).should == [f_comment.id]
  end

  it "does not list comments by authors who BLOCKed the AUDIENCE member" do
    (sn     = screen_name "main").is :WORLD
    (aud    = screen_name "audience").is :WORLD
    (friend = screen_name "friend").is :WORLD
    (meanie = screen_name "meanie").is :WORLD

    post = sn.computer({}, :WORLD)
    f_comment = friend.comments_on(post, 'I am friend.')
    m_comment = meanie.comments_on(post, 'I am meanie.')

    friend.blocks aud
    (Link.read :COMMENTS, aud, post).map(&:id).should == [m_comment.id]
  end

end # === describe 'Link.read :comments'


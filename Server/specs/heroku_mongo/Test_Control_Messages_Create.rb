# controls/Messages.rb
require 'tests/__rack_helper__'

class Test_Control_Messages_Create < Test::Unit::TestCase

  must 'allow members to create messages from a club page' do
    club = create_club
    log_in_regular_member(2)
    body = "Test body: #{self.class}: 
            allow members to create messages from a club page.
            #{rand(2000)}"
    post "/messages/", :club_filename=>club.data.filename,
      :privacy=>'public',
      :username=> regular_member(2).lifes.usernames.last,
      :body => body,
      :message_model => 'random'
    assert_equal [body], Message.find(:body=>body).map { |m| m['body'] }
  end

  must 'allow public labels (comma delimited' do
    club = create_club
    log_in_regular_member(1)
    body = "Buy it #{rand(1000)}"
    post "/messages/", :club_filename=>club.data.filename, 
      :privacy=>'public',
      :username=>regular_member(1).lifes.usernames.last,
      :body=>body,
      :message_model=>'random',
      :public_labels => 'product , knees'

    mess_labels = Message.find(
      :body=>body, 
      :target_ids=>[club.data._id]
    ).first['public_labels']
    assert_equal %w{ product knees }, mess_labels
  end

  must 'redirect to club if club_filename was specified.' do
    club = create_club
    log_in_regular_member(1)
    post "/messages/", :club_filename=>club.data.filename,
      :privacy=>'public',
      :username=> regular_member(1).lifes.usernames.last,
      :body => rand(12000)
    follow_redirect!

    assert_equal club.href, last_request.fullpath
  end

  must 'redirect to specified return url' do
    club = create_club
    log_in_regular_member(1)
    return_to = '/test/page/45-B.c/'
    post "/messages/", :club_filename=>club.data.filename,
      :privacy=>'public',
      :username=> regular_member(1).lifes.usernames.last,
      :body => rand(12000),
      :return_url => return_to

    assert_redirect return_to, 303
  end

  must 'ignore return url if is is to an external site' do
    club = create_club
    log_in_regular_member(1)
    post "/messages/", :club_filename=>club.data.filename,
      :privacy=>'public',
      :username=> regular_member(1).lifes.usernames.last,
      :body => rand(12000),
      :return_url => 'http://www.bing.com/'

    assert_redirect club.href, 303
  end
  
  # ============== CLUBS based on USERNAMES =========================

end # === class Test_Control_Messages_Create

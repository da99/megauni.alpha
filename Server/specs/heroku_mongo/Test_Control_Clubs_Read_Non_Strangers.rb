# controls/Clubs.rb
require 'tests/__rack_helper__'

class Test_Control_Clubs_Read_Non_Strangers < Test::Unit::TestCase

  must 'present a create message form for logged-in members' do
    club = create_club
    
    log_in_regular_member(1)
    get club.href_e
    form = Nokogiri::HTML(last_response.body).css('form#form_club_message_create').first
    
    assert_equal Nokogiri::XML::Element, form.class
  end

  must 'show follow club link to members.' do
    club = create_club(regular_member(1))

    log_in_regular_member(2)
    get club.href
    
    assert_equal club.href_follow, last_response.body[club.href_follow]
  end

  must 'show a form if user has multiple usernames' do
    if regular_member(3).lifes.usernames.size == 1
      Member.update(
        regular_member(3).data._id, 
        regular_member(3), 
        :add_username=>"username-#{rand(2000)}"
      )
    end

    club = create_club(regular_member(1))
    log_in_regular_member(3)
    get club.href

    assert Nokogiri::HTML(last_response.body).css('form#form_follow_create').first
  end

  must 'include club filename for :club_filename in message create form' do
    club = create_club
    
    log_in_regular_member(1)
    get club.href_e
    target_ids = Nokogiri.HTML(last_response.body).css(
      'form#form_club_message_create input[name=club_filename]'
    ).first
    
    assert_equal club.data.filename.to_s, target_ids.attributes['value'].value
  end

  must 'include member\'s username for :username in message create form' do
    club = create_club
    
    log_in_regular_member(1)
    get club.href_e
    un = Nokogiri.HTML(last_response.body).css(
      'form#form_club_message_create input[name=username]'
    ).first
    
    assert_equal regular_member(1).lifes.usernames.first, un.attributes['value'].value
  end

  must 'not show follow club link to followers.' do
    club = create_club(regular_member(1))
    club.create_follower( regular_member(2), regular_member(2).lifes._ids.first )

    log_in_regular_member(2)
    get club.href

    assert_not_equal club.href_follow, last_response.body[club.href_follow]
  end


end # === class

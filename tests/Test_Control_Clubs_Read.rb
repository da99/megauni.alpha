# controls/Clubs.rb
require 'tests/__rack_helper__'
require 'nokogiri'

class Test_Control_Clubs_Read < Test::Unit::TestCase

  def create_club(mem = nil)
    mem ||= regular_member_1
    num=rand(10000)
    Club.create(mem, 
      :title=>"R2D2 #{num}", :filename=>"r2d2_#{num}", :teaser=>"Teaser for: R2D2 #{num}"
    )
  end

  must 'be viewable by non-members' do
    club = create_club
    get "/clubs/#{club.data.filename}/"
    
    assert_match(/#{club.data.title}/, last_response.body)
  end

  must 'present a create message form for logged-in members' do
    club = create_club
    
    log_in_regular_member_1
    get club.href
    form = Nokogiri::HTML(last_response.body).css('form#form_club_message_create').first
    
    assert_equal form.class, Nokogiri::XML::Element
  end

  must 'include club filename for :club_filename in message create form' do
    club = create_club
    
    log_in_regular_member_1
    get club.href
    target_ids = Nokogiri.HTML(last_response.body).css(
      'form#form_club_message_create input[name=club_filename]'
    ).first
    
    assert_equal club.data.filename.to_s, target_ids.attributes['value'].value
  end

  must 'include member\'s username for :username in message create form' do
    club = create_club
    
    log_in_regular_member_1
    get club.href
    un = Nokogiri.HTML(last_response.body).css(
      'form#form_club_message_create input[name=username]'
    ).first
    
    assert_equal regular_member_1.usernames.first, un.attributes['value'].value
  end

end # === class Test_Control_Clubs_Read

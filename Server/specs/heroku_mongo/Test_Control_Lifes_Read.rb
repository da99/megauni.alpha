# controls/Lifes.rb

class Test_Control_Lifes_Read < Test::Unit::TestCase

  must 'render /uni/{some filename}/ for members' do
    log_in_regular_member(1)
    get "/life/#{regular_member(1).lifes.usernames.first}/predictions/"
    assert_equal 200, last_response.status
  end

  must 'show "This life is yours" to owner of life club' do
    msg = "This life is yours"
    mem = regular_member(3)
    un_id, un = mem.lifes._ids_to_usernames.to_a.first
    log_in_regular_member(3)
    life = Life.find.username(un).go_first!
    get life.href
    assert_equal msg, last_response.body[msg]
  end

  must 'allow members to post to a life club.' do
    mem = regular_member(1)
    un  = mem.lifes.usernames.first
    club = Life.find.username(un).go_first!
    body = "random content #{rand(1000)} #{un}"
    
    log_in_regular_member(1)
    
    post( '/messages/', 
      "body"=>body, 
      "body_images_cache"=>"http://28.media.tumblr.com/tumblr_l414x9008E1qba70ho1_500.jpg 500 644", 
      "username"=>un, 
      "message_model"=>"random", 
      "privacy"=>"public", 
      "club_filename"=>un
    )
  
    get club.href
    assert last_response.body[body]
  end

  must 'allow members to reply to messages in a life club.' do
    mem  = regular_member(1)
    un   = mem.lifes.usernames.first
    club = Life.find.username(un).go_first!
    mess = Message.find.target_ids( club.data._id ).limit(1).go_first!
    mess_id = mess.data._id
    
    log_in_regular_member(2)
    poster = regular_member(2)
    body = "reply to #{mess_id} #{rand 10000}"
    
    post( '/messages/', 
      "body"=>body, 
      "username"=>poster.lifes.usernames.first, 
      "message_model"=>"cheer", 
      "privacy"=>"public", 
      'return_url' => "/mess/#{mess_id}/",
      "parent_message_id"=>mess_id.to_s
    )
    
    get "/mess/#{mess_id}/"
    assert last_response.body[body]
  end

end # === class Test_Control_Lifes_Read

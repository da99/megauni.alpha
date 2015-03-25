# models/Message.rb

class Test_Model_Message_Read < Test::Unit::TestCase

  must 'by able to retrieve messages by published month' do
    mess = Message.find.
      published_at.between( 2007, 1 ).
      go!
    
    assert_equal 34, mess.size 
  end

  must 'by able to retrieve messages by month range for published at' do
    mess = Message.find.
      published_at.between( 2007, 1, 2007, 3 ).
      go!
    
    assert_equal 96, mess.size 
  end

end # === class Test_Model_Message_Read

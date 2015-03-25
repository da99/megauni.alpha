# models/Sentry_Sender.rb
require 'models/Sentry_Sender'

class Bird_Forest
  
  def received_methods
    @meths ||= []
  end

  def do_this &blok
    received_methods << :do_this
    instance_eval( &blok )
  end

  def name
    received_methods << :name
    "I am Bird_Forest."
  end

  def alive?
    received_methods << :alive?
    :yes
  end

  def economist?
    received_methods << :economist?
    :no
  end
  
  def unknown *args
    received_methods << :unknown
    args.first
  end

end # === Bird_Forest

class Test_Model_Sentry_Sender < Test::Unit::TestCase

  def bird
    @bird ||= Bird_Forest.new
  end

  def sentry
    @sentry ||= Sentry_Sender.new(bird, :unknown)
  end

  must 'evaluate if scope responds to method' do
    assert_equal :yes, sentry.instance_eval { alive? }
  end

  must 'evaluate if calls a scope method within a block' do
    assert_equal "I am Bird_Forest.", sentry.instance_eval { do_this { name } }
  end
  
  must 'send missing method to scope' do
    assert_equal :hello, sentry.instance_eval { hello }
  end

  must 'instance_eval block given to initialize method.' do
    birdy = Bird_Forest.new
    Sentry_Sender.new(birdy, :unknown) { alive? }
    assert_equal [:alive?], birdy.received_methods
  end
  
  must 'send methods to scope no matter how deep the blocks are' do
    birdy = Bird_Forest.new
    target = [:do_this, :do_this, :do_this, :do_this, :alive?]
    
    Sentry_Sender.new(birdy, :unknown) {
      do_this { do_this { do_this { do_this { alive? } } } } 
    }
    
    assert_equal target, birdy.received_methods
  end

end # === class Test_Model_Sentry_Sender

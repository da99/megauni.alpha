# models/Dyno_Cache.rb
require 'models/Dyno_Cache'

class Test_Model_Dyno_Cache_Crud < Test::Unit::TestCase

  must 'allow setting of arbitary values' do
    dyno = Dyno_Cache.new
    dyno.mutt = Class.new {
      def name
        "mutt"
      end

      def home
        "Dyno_Cache instance"
      end
    }.new
    
    assert_equal 'mutt', dyno.mutt.name
  end

  must 'raise NoMethodError if accessing a property not set.' do
    dyno = Dyno_Cache.new
    assert_raise Dyno_Cache::Not_Found do
      dyno.mutt
    end
  end

end # === class Test_Model_Dyno_Cache_Crud

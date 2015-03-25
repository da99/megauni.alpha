# models/Argumentor.rb
require 'models/Argumentor'

class Test_Helper < Test::Unit::TestCase

  must 'set arguments based on single value' do
    ops = Argumentor.argue(['just one']) {
      allow :name => nil
      single :name
    }
    assert_equal 'just one', ops.name
  end
  
  must 'set arguments based on multiple values' do
    ops = Argumentor.argue(['one', 'two']) {
      allow :first => nil, :second => nil
      multi :first, :second
    }
    
    assert_equal %w{ one two }, [ops.first, ops.second]
  end

  must 'set arguments based on order and number of values' do
    ops = Argumentor.argue(['one', 'two']) {
      allow :first => nil, :second => nil
      multi :second, :first
    }
    
    assert_equal %w{ two one }, [ops.first, ops.second]
  end

  must 'set non-specified arguments using defaults.' do
    ops = Argumentor.argue(['one']) {
      allow :first => nil, :second => 'default two'
      single :first
      multi :second, :first
    }
    
    assert_equal 'default two', ops.second
  end

end # === class Helper

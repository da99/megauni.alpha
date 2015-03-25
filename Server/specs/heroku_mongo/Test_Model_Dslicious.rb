# modules/Dslicious.rb

require 'modules/Dslicious'

class DSL
  include Dslicious
end

class Test_Model_Dslicious < Test::Unit::TestCase

  def dsl &blok
    DSL.new.instance_eval(&blok)
  end

  must 'permutate: create every combination for: [:a, :b], [:c, :d]' do
    first  = [:a, :b]
    second = [:c, :d]
    target = [[:a, :c], [:a, :d], [:b, :c], [:b, :d]]
    result = dsl { permutate(first, second) }
    assert_equal target, result
  end

  must ':all_true?: return true if all elements are truthy' do
    result = dsl { all_true? [ true, 1, 2 ] }
    assert_equal true, result
  end

  must ':all_true?: return false if one element is nil' do
    result = dsl { all_true? [ true, nil, 2] }
    assert_equal false, result
  end

  must ':all_true?: return false if one element is false' do
    result = dsl { all_true? [ true, false, 2] }
    assert_equal false, result
  end

  must ':all?: return true if all elements eval truthy after applying block' do
    result = dsl {
      all? [2,3,4] do
        size == 3
      end
    }
    
    assert true, result
  end

  must ':inside_map: return mapped values' do
    result = dsl {
      inside_map(%w{who this genius is}) { upcase }
    }
    
    assert_equal %w{WHO THIS GENIUS IS}, result
  end
end # === class Test_Model_Dslicious

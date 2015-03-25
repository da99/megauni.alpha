# models/Diff_Document.rb

require 'models/Diff_Document'

class Test_Model_Diff_Document_Create < Test::Unit::TestCase
  
  def o
    @o_hash_diff ||= begin
                       {}.extend Mongo_Dsl::Diff_Document
                     end
  end

  must 'return an Array diff for String values' do
    o['body'] = "He wanted the water."
    c = {'body' =>"She wanted the plasma."}
    
    diff = o.diff_document(c)
    
    target = {'body' => [["He", "She"], " wanted the ", ["water", "plasma"], "."] }
    assert_equal target['body'], diff['body']
  end

  must 'return an diff for Array inserted values' do
    o['tags'] = [:a]
    c = {'tags' => [:c, :a] }
    
    diff = o.diff_document(c)
    
    target = {'tags' => [['+', [:c]] ] }
    assert_equal target['tags'], diff['tags']
  end

  must 'return an diff for Array deleted values' do
    o['tags'] = [:a, :b, :c]
    c = {'tags' => [:c, :a] }
    
    diff = o.diff_document(c)
    
    target = {'tags' => [['-', [:b]] ] }
    assert_equal target['tags'], diff['tags']
  end
  
  must 'return a diff for String values changed to Fixnum values' do
    o['price'] = 'Free'
    c = {'price' => 20 }
    
    diff = o.diff_document(c)
    
    target = {'price' => ['-+', 'Free', 20]}
    assert_equal target['price'], diff['price']
  end
  
  must 'return a diff for Fixnum values changed to Float values' do
    o['price'] = 20
    c = {'price' => 20.50 }
    
    diff = o.diff_document(c)
    
    target = {'price' => ['-+', 20, 20.50]}
    assert_equal target['price'], diff['price']
  end
  
  must 'return a diff for Float values changed to Fixnum values' do
    o['price'] = 10.50
    c = {'price' => 20 }
    
    diff = o.diff_document(c)
    
    target = {'price' => ['-+', 10.50, 20]}
    assert_equal target['price'], diff['price']
  end
  
  must 'return a diff for Float values changed to String values' do
    o['price'] = 10.50
    c = {'price' => 'Free' }
    
    diff = o.diff_document(c)
    
    target = {'price' => ['-+', 10.50, 'Free']}
    assert_equal target['price'], diff['price']
  end
  
  must 'return a diff for NilClass values changed to String values' do
    o['title'] = nil
    c = {'title' => 'Free' }
    
    diff = o.diff_document(c)
    
    target = {'title' => ['-+', nil, 'Free']}
    assert_equal target['title'], diff['title']
  end
  
  must 'return a diff for FalseClass values changed to String values' do
    o['title'] = false
    c = {'title' => 'Free' }
    
    diff = o.diff_document(c)
    
    target = {'title' => ['-+', false, 'Free']}
    assert_equal target['title'], diff['title']
  end
  
  must 'return a diff for String values changed to NilClass values' do
    o['title'] = 'Free'
    c = {'title' => nil }
    
    diff = o.diff_document(c)
    
    target = {'title' => ['-+', 'Free', nil]}
    assert_equal target['title'], diff['title']
  end

end # === class Test_Model_Diff_Document_Create

class MiniIssue < Sequel::Model
  def self.create(title, body)
    r = new
    coder = HTMLEntities.new
    r[:title] = coder.encode( title, :named )
    r[:body]  = coder.encode( body, :named )
    r[:created_at] = Time.now.utc
    r.save
  end
  def before_save 
    self[:created_at]= Time.now.utc
    super
  end    
  def before_update
    self[:modified_at] = Time.now.utc
    super
  end  
  def resolve
    self[:resolved] = true
    save(:changed=>true)
  end
end

class FailedAttempts
  def self.fails(env)
    @fails ||= {}
    @fails[ env ] ||= 0
  end
    
  def self.increase(env)
    fails( env ) 
    @fails[env] += 1
  end

  def self.too_many?(env)
    fails(env) > 3
  end
end # === class

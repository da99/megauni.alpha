
class Method_Air_Bags

  Method_Collision = Class.new(StandardError)

  def self.open_if_collision one, two
    errs = one.instance_methods & two.instance_methods
    if !errs.empty?
      raise Method_Collision, "These methods collide between #{one.inspect} and #{two.inspect}: #{errs.inspect}"
    end
  end
  
end # === Method_Air_Bags

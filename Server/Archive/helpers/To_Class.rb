
module Symbol_To_Class

  def to_singular
    to_s.sub(/s\z/, '')
  end
    
  def to_class_name
    to_s.split('_').map(&:capitalize).join('_')
  end
  
  def to_model_class_name
    to_s.to_singular.to_class_name
  end
  
  def to_class
    Object.const_get self
  end

end # === module Symobol_To_Class

module String_To_Class

  def must_not_be_empty
    raise "String can't be empty for this operation." if empty?
    self
  end

  def to_singular
    sub(/s\z/, '')
  end
    
  def to_class_name
    must_not_be_empty
    split('_').map(&:capitalize).join('_')
  end
  
  def to_model_class_name
    to_singular.extend(String_To_Class).to_class_name
  end
  
  def to_class
    must_not_be_empty
    Object.const_get self.to_sym
  end

end # === module String_To_Class


module To_Class
  
  class << self
    
    def extended obj
      case obj
        when Symbol
          obj.extend Symbol_To_Class
        when String
          obj.extend String_To_Class
        else
          raise "I don't know what to do with this: #{obj.inspect}"
      end
    end

  end # === class

end # === modile

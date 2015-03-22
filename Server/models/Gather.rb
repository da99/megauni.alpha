
class Gather
  attr_reader :_ast_, :_defines_, :_gathers_

  def initialize &blok
    @_ast_ = []
    @_defines_ = {}
    @_gathers_ = {}
    instance_eval(&blok) if block_given?
  end

  def method_missing name, *args, &blok
    if _define_.has_key?(name)
      return _define_[name]
    end
    
    if _gathers_.has_key?(name)
      _gathers_[name][args.first] = [args, blok]
    end
    
    _ast_ << [name, args, blok && Gather.new.instance_eval( &blok )]
    self
  end
  
  def _define_ name, val
    @_defines_[name.to_sym] = val
  end
  
  def _gather_ name
    @_gathers_[name.to_sym] ||= {}
  end
  
end


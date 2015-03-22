
class Argumentor

  class Bag
    
    def initialize hash
      hash.each { |key, val|
        eval %~
          def self.#{key}
            #{val.inspect}
          end
        ~
      }
    end

  end # === class Bag

  def self.argue args, &blok
    obj = new
    obj.instance_eval {
      @args   = args
      @allow  = []
      @order  = []
      @values = {}
    }
    obj.instance_eval( &blok )
    obj.argue args
  end
  
  def allow raw_hash
    hash = raw_hash.to_a.map { |pair|
      [pair.first.to_sym, pair.last]
    }
    @values = @values.merge( Hash[*(hash.flatten)] )
    @args   = ( @args + @values.keys )
    @values
  end
  
  def single raw_key
    multi raw_key
  end

  def multi *args
    if @order[args.size]
      raise ArgumentError, "Argument size taken: #{@order[args.size].inspect}. New: #{args.inspect}" 
    end
    @order[args.size] = args
  end

  def argue args
    unless @order[args.size]
      raise ArgumentError, "Invalid number of arguments: #{args.inspect}"
    end
    
    @order[args.size].each_index { |index|
      name          = @order[args.size][index]
      @values[name] = args[index]
    }
    
    Bag.new( @values )
  end

end # === class Argumentor

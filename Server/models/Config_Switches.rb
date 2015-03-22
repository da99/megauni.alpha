
class  Config_Switches

  attr_reader :store, :ask, :put, :get, :get_or_put

  def initialize &blok
    @store = {}
    
    accessor = Class.new {
      attr_reader :config
      
      def initialize new_config
        @config = new_config
      end
      
    }
    
    %w{ask put get get_or_put}.each { |prop|
      eval %~
        @#{prop} = accessor.new(self)
      ~
    }
    
    def put.validate_value( val, vals )
        unless vals.include?(val)
          raise "Invalid value: #{val.inspect}. Allowed: #{vals.inspect}"
        end
        val
      end

    if block_given?
      instance_eval( &blok )
    end
  end
    
  def as_hash *keys
    keys.inject({}) { |memo, k|
      memo[k] = get.send(k)
      memo
    }
  end

  def put &configuration
    if block_given?
      @put.instance_eval( &configuration )
    end
    @put
  end

  def on
    true
  end
  
  def off
    false
  end
  
  def strings *args
    args.each { |field|
      define_ask field
      eval %~
        def get.#{field}
          config.store[:#{field}]
        end

        def put.#{field} val
          config.store[:#{field}] = val
        end
      ~
    }
  end
  alias_method :string, :strings

  def arrays *args
    args.each { |field|
      define_ask field
      eval %~
        def get.#{field}
          config.store[:#{field}] ||= []
        end
        
        def put.#{field} *args
          config.store[:#{field}] = if args.is_a?(Array) && args.first.is_a?(Array) &&args.size == 1
                                      args.first
                                    else
                                      args
                                    end
        end
      ~
    }
  end
  alias_method :array, :arrays

  def hashes *args
    args.each { |field|
      define_ask field
      eval %~
        def get.#{field}
          config.store[:#{field}] || {}
        end

        def put.#{field} hsh
          config.store[:#{field}] = hsh
        end
      ~
    }
  end
  alias_method :hash, :hashes

  def string_or_block *args
    args.each { |name|
      define_ask name
      eval %~
        def get.#{name}
          config.store[:#{name}] || []
        end
        
        def put.#{name} str = nil, &blok
          config.store[:#{name}] = [str, blok]
        end
      ~
    }
  end

  def switch name, default = nil
    if default.nil?
      default = off
    end

    define_ask name
    
    eval %~
      def get.#{name}_up
        !#{default}
      end
    
      def get.#{name}_down
        #{default}
      end
    
      def get.#{name}
        config.store.has_key?(:#{name}) ?
          config.store[:#{name}] :
          #{name}_down
      end
    
      def put.#{name}
        config.store[:#{name}] = config.get.#{name}_up
      end
    ~
  end
  
  def levels name, raw_values, default
    values                         = (raw_values + [default]).uniq
    used_name                      = "#{name}s_used"
    store["#{name}_valids".to_sym] = values
    store_name                     = "config.store[:#{name}]"
    store_valids                   = "config.store[:#{name}_valids]"
    store_used                     = "config.store[:#{used_name}]"
    get_used                       = "config.get.#{used_name}"
    
    define_ask        name
    define_get_or_put name
    
    eval %~
      def get.#{name}
        config.store.has_key?(:#{name}) ?
          #{store_name} :
          #{default.inspect}
      end
      
      def get.#{used_name}
        #{store_used} ||= []
      end

      def put.#{name} val
        val           = validate_value(val, #{store_valids})
        #{store_name} = val
        (#{get_used} << val) unless #{get_used}.include?(val)
        val
      end
    ~
  end
  
  def define_ask name
    get_name = "config.get.#{name}"
    eval %~
      def ask.#{name}?
        case #{get_name}
          when Array, Hash
            !#{get_name}.empty?
          else
            !!#{get_name}
          end
      end
    ~
  end

  def define_get_or_put name
    eval %~
      def get_or_put.#{name} *args
        if args.empty?
          config.get.#{name}
        else
          config.put.#{name} *args
        end
      end
    ~
  end

end # === class Config_Switches

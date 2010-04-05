
class Data_Pouch

  def initialize raw_doc, *field_arr
    @fields       = field_arr.flatten.map(&:to_s) 
    @doc          = {}
    
    # Fill @doc hash with only allowed fields.
    @fields.each { |f| 
      @doc[f] = Data_Pouch.clean(raw_doc[f] || raw_doc[f.to_sym])
    }
  end

  def respond_to?(raw_meth)
    meth = raw_meth.to_s
    @fields.include?(meth) || @fields.include?(meth.sub(/=\Z/, '')) || super(raw_meth)
  end

  def method_missing *args
    
    raw_field = args.first.to_s
    field = raw_field.sub('=', '')
    
    # Check if accessing a value.
    if args.size == 1 && @fields.include?(field)
      return @doc[field]
    end

    # Check if setting a field.
    if args.size == 2 && raw_field['='] && @fields.include?(field)
      return @doc[field] = Data_Pouch.clean(args[1])
    end

    super
  end

  def include?(val)
    @fields.include?(val.to_s)
  end

  alias_method :has_key?, :include?

  def as_hash
    Data_Pouch.clean(@doc)
  end

  def self.clean hsh
    case hsh
    when Array
      hsh.map { |val| Loofah::Helpers.sanitize(val) }
    when Hash
      hsh.to_a.inject({}) { |m, (k, v)| 
        m[k] = clean(v)
        m
      }
    when Numeric
      hsh
    when NilClass
      nil
    else
      hsh && Loofah::Helpers.sanitize(hsh.to_s)
    end
  end
end # ======== Data_Pouch

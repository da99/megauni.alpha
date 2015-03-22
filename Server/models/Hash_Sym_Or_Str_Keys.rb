

class Hash_Sym_Or_Str_Keys < Hash
  def [](k)
    case k
    when Symbol
      super(k) || super(k.to_s)
    when String
      super(k) || super(k.to_sym)
    else
      super
    end
  end
end # === class


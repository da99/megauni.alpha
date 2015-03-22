#
# Data object that takes in a Hash, allows accessor methods
# and boolean methods to be used.
#
# It's strict. If you ask for a non-existent value,
# even with a boolean method, it raises a NameError.
#
# Example:
#
#   i = InterrogatedOptions.new(:name=>'Hermes Conrad', :job=>'Bureaucrat')
#   
#   i.name     # ==> 'Hermes Conrad'
#   i.name?    # ==> true
#
#   i.address? # ==> NameError raised.
#   i.address  # ==> NameError raised.
#
class InterrogatedOptions
  
  private
    attr_accessor :opts
    attr_accessor :opts_qm # keys of :opts but with question marks

  public 

  def initialize oHash
    self.opts = oHash
    self.opts_qm = self.opts.inject({}) { |m, (k,v)|
      m[(k.to_s+'?').to_sym] = k
      m
    }
  end

  def method_missing *args
    if args.size === 1
      k = args.first.to_sym
      return opts[k] if opts.has_key?(k)
      return !!opts[opts_qm[k]] if opts_qm.has_key?(k)
    end
    super(*args)
  end

end # === InterrogatedOptions


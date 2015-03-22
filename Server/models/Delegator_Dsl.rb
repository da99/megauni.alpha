
module Delegator_Dsl
  
  def delegate_to receiver, *raw_meths
    meths = raw_meths.flatten.compact.uniq
    raw_meths.each { |meth|
      module_eval %~
        def #{meth} *args
          #{receiver}.#{meth} *args
        end
      ~
    }
  end
  
end

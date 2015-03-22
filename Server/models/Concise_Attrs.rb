
module Concise_Attrs
  def attr_concise *fields
    this = self
    class_eval {
      fields.each { |fld|
        eval %~
          def #{fld} *args
            return @#{fld} if args.empty?
            return @#{fld} = args.first if args.size === 1
            @#{fld} = args
          end
            
          def #{fld}?
            !!@#{fld}
          end
        ~
      }
    }
  end 
end # === module Concise_Attrs


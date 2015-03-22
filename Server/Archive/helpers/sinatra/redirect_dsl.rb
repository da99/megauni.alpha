def redirect &blok

  RedirectDSL.new &blok 
end


configure do

  class RedirectDSL
  
    def initialize &blok

      instance_eval( &blok )
      
      if !@from || !@to
        raise ArgumentError, "Both need to be set: :to, :from (#{@to.inspect}, #{@from.inspect})"
      end 
      
      @from.each { |f|
            
        line = __LINE__
        code = %~
         get #{f.inspect} do 
          redirect #{@to.inspect}
         end
        ~
        self.class.instance_eval code, __FILE__, line

      }

    end

    def from *args
      @from = args.flatten.map { |f|  normalize_path(f) }
    end
    
    def to path_or_regex
      @to = normalize_path(path_or_regex)
    end

    private # =====================================

    def normalize_path path
      case path
        when Symbol
          "/#{path}/"
        else
          path
      end
    end

  end # === RedirectDSL

end # === configure


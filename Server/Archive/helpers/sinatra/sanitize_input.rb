helpers {

  def clean_room
    @clean_room ||= params.inject({}) { |m, (k, val)|
      m[k.to_sym] = case val
        when Array
          val.map { |s| Wash.html(s.to_s) }
        when Hash
          val.inject({}) { |m2, (k2, v2)|
            m2[k2.to_sym] = Wash.html(v2.to_s)
          }
        else
          s = val.to_s.strip
          s.empty? ?
              nil :
              Wash.html(s)
      end

      m
    }
  end

  def integerize_splat_or_captures
      raw_vals = ( params[:splat] || params[ :captures ] )
      raise "No Integers/IDs found."  unless raw_vals
      raw_vals.map { |raw_i| 
          raw_i.split('/').map { |i|
              Integer(i) unless i.strip.empty?
          }
       }.flatten.compact
  end # === integerize_splat_or_captures

} # === helpers

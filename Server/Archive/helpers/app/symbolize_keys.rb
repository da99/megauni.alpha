class Hash

  def symbolize_keys
    inject({}) do |m, (k,v)|
      new_k = begin
        k.to_sym
      rescue NoMethodError
        k
      end

      new_v = begin
        v.symbolize_hash_keys # if Array
      rescue NoMethodError
        begin 
          v.symbolize_keys # if Hash
        rescue NoMethodError
          v # if not any of the above
        end
      end

      m[new_k] = new_v
      m
    end
  end

end # class Hash


class Array

  def symbolize_hash_keys
    inject([]) do |m,v|
      if v.respond_to? :symbolize_keys
        m << v.symbolize_keys
      else
        m << v
      end

      m
    end
  end

end # class Array

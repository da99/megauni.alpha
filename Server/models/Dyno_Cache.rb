
class Dyno_Cache
  
  Not_Found = Class.new(RuntimeError)
  
  def initialize
    @the_cache = {}
  end

  def method_missing name, *vals
    found = case vals.size
            when 0
              @the_cache[name] if @the_cache.has_key?(name)

            when 1
              name_s = name.to_s
              if not name_s['=']
                false
              else
                name_get = name_s.sub('=', '').to_sym
                @the_cache[name_get] = vals.first
              end
            end
    
    return found if found
    raise( Not_Found, "#{name.inspect} not found in this store." )
  end

end # === class

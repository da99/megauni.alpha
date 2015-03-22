
require 'json' # Mainly used by CouchDB.


def json_parse(str)
  results = JSON.parse(str)
  case results
    when Hash
      results.extend Sym_Keys_For_Hash
      results.symbolize_keys
    when Array
      results.symbolize_hash_keys
    else
      results
  end
end

module Sym_Keys_For_Hash

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

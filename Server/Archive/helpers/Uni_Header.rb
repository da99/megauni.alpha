
module Sinatra

  module Uni_Header

    def env_key raw_find_key
      find_key = raw_find_key.to_s.strip
      if env.has_key?(find_key)
        return env[find_key]
      end
      raise ArgumentError, "Key not found: #{find_key.inspect}"
    end

    # Returns an array of acceptable media types for the response
    def allowed_mime_types
      @allowed_mime_types ||= @env['HTTP_ACCEPT'].to_s.split(',').map { |a| a.strip }
    end

    def no_cache
      header :cache_control, 'no-cache'
    end

    def header? key
      !!(header key)
    end

    # This method does a lot. 
    # But, it's simple and prevents me from
    #   writing a bunch of little get/set/set?/etc 
    #   methods.
    def header *args
      
      return_header = case args.size
                      when 1
                        true
                      when 2
                        false
                      when 0
                        raise ArgumentError, "Arguments empty."
                      else
                        raise ArgumentError, "Too many arguments: #{args.inspect}"
                      end

      @valid_headers ||= %w{
        Accept-Charset
        Content-Disposition
        Content-Type
        Content-Length
        Cache-Control
      }
      
      charset = ( @default_charset ||= 'charset=utf-8' )
      
      raw_key, val = args
      key_s        = raw_key.to_s
      key_up       = key_s['_'] ? key_s.split('_').map(&:capitalize).join('-') : key_s
      
      return response[key_up] if return_header

      response[key_up] = case key_up
                         when 'Accept-Charset'
                           case val
                           when 'utf-8'
                             val
                           else
                             raise ArgumentError, "Unknown charset: #{val.inspect}"
                           end
                         when 'Content-Disposition' 
                           "attachmet; filename=#{val}"
                         when 'Content-Length'
                          val
                         when 'Cache-Control'
                          val
                          
                         when 'Content-Type'
                           case val.to_sym
                           when :html, :xml, :text
                             mime_type(".#{val}") + '; ' + charset
                           else
                             raise ArgumentError, "Unknown Content-Type: #{type.inspect}"
                           end
                          
                         else
                           raise ArgumentError, "Invalid header key: #{key.inspect}"
                          
                         end # === case

    end # === def header

  end # === module Uni_Header

  helpers Uni_Header

end # === module Sinatra


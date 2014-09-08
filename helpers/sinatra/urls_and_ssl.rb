
before {
  
  # url must not be blank. Sometimes I get error reports where the  URL is blank.
  # I have no idea how that is even possible, so I put this:
  if production? && 
    ( env['REQUEST_URI'].to_s.strip.empty? || 
        request.path_info.to_s.strip.empty? )
    raise( ArgumentError, "POSSIBLE SECURITY ISSUES: URL is blank: #{env['REQUEST_URI'].inspect}, #{request.path_info.inspect}" ) 
  end
  
  halt( 404, "404 - Not Found" ) if blacklisted_robot?

    
} # === before  

helpers {

    # :redirect is over-ridden here because of :keep_flash 
    # (part of custom flash implementation)
    def redirect(uri, *args)
      if !request.get? && args.detect { |s| s.to_i > 200 && s.to_i < 500 }
        raise ArgumentError,
              "No status code allowed for non-GET requests: #{args.inspect}"
      end
      if request.get? || request.head?
        status 302
      else
        status 303
      end

      keep_flash

      response['Location'] = uri
      halt(*args)
    end

    def publicize_path(path)
     File.join( options.public, Wash.path( path ) )
    end

    # Adds either http:// or https://, 
    # along with request.host
    # depending if logged in.
    def urlize(url)
      base = response.url.split('/')[0,3].join('/')
      File.join( base, url)
    end
    
    
    # ==== SSL =================================================

    def using_ssl?
      (env['HTTPS'] == 'on' || 
          env['HTTP_X_FORWARDED_PROTO'] =='https' || 
            env['rack.url_scheme'] == 'https' )
      # This: request.url =~ /\Ahttps\:/ 
      # does not work if being used in a proxy setup.
    end
    
    def require_ssl!
    
      return nil if using_ssl?
      
      if request.xhr? || request.post?
        render_error_msg( 200, "Programmer error. Using unsecure line."  )
      end
            
      # Redirect to SSL
      # SSL detection from: http://www.ruby-forum.com/topic/155956
      redirect 'https://' + request.url.sub('http://', '') , 301 # permanent redirect

    end # === def 

    # ==== 404 Helpers ===========================================
    # ==== Mainly used in  :not_found

    # Some :GET requests should not be redirected,
    # like those with QUERY_STRING of Ajax requests (:xhr?).
    def redirectable_get?
       request.get? && 
      !request.xhr? && 
       request.query_string.to_s.strip.empty?
    end

    def add_slash_to_path_info( path = nil )
      path ||= request.path_info
      
      if path != '/' &&  # Request is not for homepage.
         path !~ /\.[a-z0-9]+\z/ &&  # Request is not for a file.
         path[ path.size - 1 , 1] != '/'  # Request does not end in /

        return path + '/'
      end

      path 
    end

    # Add trailing slash and use a permanent redirect (301)
    # by default.
    # Why a trailing slash? Many software programs
    # look for files by appending them to the url: /salud/robots.txt
    # Without adding a slash, they will go to: /saludrobots.txt.
    def redirect_to_slashed_path_info http_code = 301
      return false if !redirectable_get?

      if request.path_info != add_slash_to_path_info 
        redirect( add_slash_to_path_info, 301 )
      end
      false
    end

    def redirect_to_downcased_path_info
      return false if !redirectable_get?

      uri_downcase = request.path_info.downcase

      if uri_downcase != request.fullpath
        redirect uri_downcase
      end

      false
    end


} # === helpers



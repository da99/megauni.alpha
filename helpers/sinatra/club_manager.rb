

# ============= Include lib files.
# require Pow!( '../lib/wash' )
# require Pow!( '../lib/to_html' )

set :valid_resource_actions, [:view, :index, :show, :create, :list, :edit, :update, :trash, :untrash]

helpers do # ===============================   

    # ==================================================================
    # Ajax helpers.
    # ==================================================================

    def to_js_epoch_time(epoch_time)
      epoch_time.to_i * 1000
    end

    def render_success_msg(msg)
      describe_action :Main, :success_msg
      delete_form_draft_cookie
      @success_msg = msg
      @partial ||= template_name
      
      halt( 200, render_mab )
    end

    
    def render_error_msg( http_error_code, msg)
        describe_action :Main, :error_msg
        @error_msg = msg
        halt( 200, render_mab)
    end

    # === Miscellaneous helpers ========================
    def publicize_path(path)
     File.join( options.public, Wash.path( path ) )
    end

    def clean_room
      @clean_room = params.inject({}) { |m, (k, val)|
        if val.to_s.strip.empty?
            m[k] = nil
        else
            m[k] = Wash.plaintext(val)
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
    
    def dev_log_it( msg )
        puts(msg) if options.development?
    end                    
    
    # === Member related helpers ========================
    
    def urlize(url)
      return url if !url[/^\//]
      return "http://#{request.host}#{url}" if !logged_in?
      "https://#{url}"
    end
    
    def socket_and_host
      "http#{ using_ssl? ? 's' : '' }://#{request.host}"
    end
    
    def using_ssl?
      (env['HTTPS'] == 'on' || 
          env['HTTP_X_FORWARDED_PROTO'] =='https' || 
            env['rack.url_scheme'] == 'https' || 
              request.port == 443)
      # This: request.url =~ /\Ahttps\:/ 
      # does not work if being used in a proxy setup.
    end
    
    def require_ssl!
    
      return nil if using_ssl?
      
      if request.xhr? || request.post?
        render_error_msg( "Programmer error. Using unsecure line.", 200  )
      end
            
      # Redirect to SSL
      # SSL detection from: http://www.ruby-forum.com/topic/155956
      redirect 'https://' + request.url.sub('http://', '') , 301 # permanent redirect

    end # === def 
    
    
    def logged_in?
      session[:member_username] && !current_member.new?
    end # === def      

    def current_member=(mem)
        raise "CURRENT MEMBER ALREADY SET" if mem && session[:member_username]
        session[:member_username] = mem.username
    end    

    def current_member
      return nil if !session[:member_username]
      @current_member ||= Member[:username => session[:member_username] ]
      return nil unless @current_member
      @current_member
    end # === def
    
    def check_creditials!
      
      dev_log_it("CREDITIAL CHECK >>> #{current_action[:controller].inspect} #{current_action[:action].inspect}")
      
      return true if logged_in? && current_member.has_power_of?( current_action[:perm_level] )
      return true if current_action[:perm_level].eql?( :STRANGER )
      
      if request.get?
        session[:desired_uri] = request.env['REQUEST_URI']
        redirect('/log-in')
      else
        render_error_msg( "Not logged in. Login first and try again.", 200  )
      end
      
    end # === def check_creditials!            
    
    
    # === Action related helpers. ===========================
       def current_action
            @current_action_props
       end 
                      
       def describe(c_name, a_name)
          @current_action_props = {  :action => a_name, 
                            :path=>request.path_info, 
                            :http_verb=>request.request_method, 
                            :controller =>c_name }                           
       end
       
       def protected_for( *args )
          level, c_name, a_name = args
          describe c_name, a_name
          current_action[:perm_level] = level
          check_creditials!
          yield
       end
            
        def strigify_proc( raw_proc )
            raw_proc.to_ruby.gsub( /^proc \{|\}$/, '' )
        end 
    
end # === helpers
        
        


__END__


  def error
  
    response['Content-Type'] = 'text/html' # In case the controller changed it, like the CSSController.

    if BusyConfig.development?
      return error_wo_customizations if request.get?

      error = Ramaze::Dispatcher::Error.current
      title = error.message

      respond %(
        <div class="error_msg">
          <div class="title">#{error.message}</div>
          <div class="msg"><pre>
            #{PP.pp request, '', 200}
            <br /><hr /><br />
            #{error.backtrace.join("\n            ")}
          </pre></div>
        </div>
      ).ui
      
    end
    

    
    begin
      respond Pow!('../public/500.html').read
    rescue
      respond %~
        <html>
          <head>
            <title>Error Page</title>
          </head>
          <body>
            Something went wrong. Check back later :(
          </body>
        </html>
      ~.unindent
    end
      
  end

   # ==================================================================
    # Methods to handle permission levels.
    # ==================================================================
    def __perm_levels__
      @perm_levels ||={}
    end

    def set_permission_level( new_level, *actions )
      actions.each { |raw_target_action| 
        target_action = raw_target_action.to_sym
        if __perm_levels__.has_key?(target_action)
          raise PermissionLevelAlreadySet,  "Permission level can not be set more than once: #{raw_target_action.inspect}" 
        end
        __perm_levels__[target_action] = new_level
      }
    end

    def get_permission_level(target_action)
      __perm_levels__.fetch( target_action.to_sym,  Member::NO_ACCESS )
    end


module Sinatra
  
  module Uni_Guard
    
    def clean_room
      @clean_room ||= begin
                        data = Hash_Sym_Or_Str_Keys.new
                        
                        # NOTE: request.params returns empty Hash
                        params.each { |k,v| 
                          data[k.to_s.strip] = case v
                                               when String
                                                 temp = Loofah::Helpers.sanitize(v.strip)
                                                 temp.empty? ? nil : temp
                                               when Array
                                                 v.map { |arr_v| 
                                                   Loofah::Helpers.sanitize(arr_v.strip)
                                                 }
                                               else
                                                 raise "Unknown class: #{v.inspect} for #{k.inspect} in #{request.params.inspect}"
                                               end
                        }
                        
                        data
                      end
    end

    
    # === Session-related helpers ===

    def session
      env['rack.session'] ||= {}
    end

    def flash_msg
      env['flash.msg']
    end

    def min_security_level level
      case level.to_s
      when Member::NO_ACCESS
        raise "NO_ACCESS"
      when Member::STRANGER
        true
      else
        require_log_in!
        raise "Invalid security level" unless current_member.has_power_of?( level )
        true
      end
    end

    def require_log_in! *perm_levels

      return true if perm_levels.empty? && logged_in?

      if not logged_in? 
        if request.get? || request.head? || !request.xhr?
          session[:return_page] = request.fullpath
          redirect!('/log-in/')
        elsif request.xhr?
          error! %~<div class="errors"> Not logged in. Log-in first and try again. </div>~, 401
        else
          raise "This part of the app not finished."   
        end
      end

      power = perm_levels.detect { |level| 
        current_member.has_power_of?(level) 
      }

      if not power
        error!( nil, 403)
      end

      true
    end 

    def log_out!
      return_page = session.delete(:return_page)
      session.clear
      session[:return_page] = return_page
    end 

    def logged_in?
      session[:member_id] && current_member && !current_member.new?
    end # === def      

    def current_member=(mem)
      raise "CURRENT MEMBER ALREADY SET" if logged_in?
      session[:member_id] = mem.data._id
    end    

    def current_member
      return nil if !session[:member_id]
      @current_member ||= Member.by_id( session[:member_id] )
    end # === def

  end

  helpers Uni_Guard

end # === module Uni_Guard

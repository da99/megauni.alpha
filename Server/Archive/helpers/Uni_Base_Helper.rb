require 'models/Dyno_Cache'

module Sinatra
  module Uni_Base_Helper

    def the_message
      the.id = clean[:id]
      the.message = Message.find._id(the.id).go_first!
    end

    def the_club
      the.filename = clean_room[:filename]
      the.club = Club.find.filename(the.filename).go_first!
    end

    def the_club_with messages
      action :"read_#{request.path_info.split('/').last}"
      the_club
      results = the.club.find.messages.send(messages).merge(:owner).go!
      the.send("#{messages}=", results  )
    end

    def the_life
      the.username = clean_room[:filename]
      the.life = Life.find.username(the.username).go_first!
      the.owner = the.life.find.owner.go_first!
      the.life
    end
    
    def the_life_with messages
      the_life
      the.send("#{messages}=", the.life.find.messages.send(messages).go! )
    end

    def current_path path = :show_me_current_path
      case path
      when :show_me_current_path
        raise ArgumentError, "Current path not set." if !@current_path
        @current_path
      else
        raise ArgumentError, "Current path already set: #{@current_path}" if @current_path
        @current_path = path
      end
    end

    def redirect! raw_url
      url = expand_url( raw_url )
      redirect url
    end

    def redirect_back_or raw_url
      url   = expand_url( raw_url )
      go_to = [ session[:return_to], back, url ].compact.first
      redirect go_to
    end
    
    def expand_url txt
      # add slash at end
      if not txt['.']
        txt = File.join( txt, '/')
      end
      
      # if url starts with "../"
      if txt['../']
        txt = File.join( base_path, txt.gsub('../', '') )
      end
      
      txt
    end

    def lang
    'en-us'
    end

    def the
      @the_cache ||= Dyno_Cache.new
    end

    def stardardize_year yr
      year = yr.to_i
      year += 2000 if year < 100
      year
    end

    def stardardize_month mt
      month = mt.to_i
      month = 1 if month < 1
      month
    end
    
    def stardardize_date_range yr, mt = 0
      year  = stardardize_year( yr )
      month = stardardize_month( mt )
      case month
      when 1
        prev_month = Time.utc(year - 1, 12)
        next_month = Time.utc(year + 1, 2)
      when 12
        prev_month = Time.utc(year, 11)
        next_month = Time.utc(year, 1)
      else
        prev_month = Time.utc(year, month-1)
        next_month = Time.utc(year, month+1)    
      end
      [ year, month, prev_month, next_month]
    end

    def cache_for min 
      header :cache_control, "public, max-age=#{min * 60}"
    end

    def describe key, value = :_show_this_value_
      @the_meta_of_the_app ||= begin
                                 new_meta = Dyno_Cache.new
                                 the.meta_of_the_app = new_meta
                                 new_meta
                               end
      case value
      when :_show_this_value_
        the.meta_of_the_app.send(key)
      else
        the.meta_of_the_app.send("#{key}=", value)
      end
    end

    def control *vals
      describe :control, *vals
    end

    def action *vals
      describe :action, *vals
    end
    
    def base_path *vals
      describe :base_path, *vals
    end


    # ------------------------------------------------------------------------------------
    private # ----------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------

    def success_msg *args
      return @success_msg if args.empty?
      @success_msg = args.first
    end

  end # === module Uni_Base_Helper
  
  helpers Uni_Base_Helper
end # === Sinatra

__END__

  
  # def redirect_back! *args
  #   args[0] = env['HTTP_REFERER'] || args[0]
  #   redirect! *args
  # end

  # def redirect! *args
  #   render_text_plain ''
  #   
  #   # If HTTP Code not specified, use 303.
  #   # This forces redirect as a GET.
  #   if not args.last.is_a?(Integer)
  #     args << 303 
  #   end
  #   
  #   response.redirect( *args )
  #   raise Uni_App::Redirect
  # end

  # def not_found! body
  #   error! body, 404
  # end

  # # Halt processing and return the error status provided.
  # def error!(body, code = 500)
  #   response.status = code
  #   response.body   = body unless body.nil?
  #   raise Uni_App.const_get("HTTP_#{code}")
  # end

require 'mustache'

FIND_URLS = %r~\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.])(?:[^\s()<>]+|\([^\s()<>]+\))+(?:\([^\s()<>]+\)|[^`!()\[\]{};:'".,<>?«»“”‘’\s]))~

class Array
  
  def map_html_menu &blok
    
    map { |orig|
      raw_results = blok.call(orig)
      
      selected, attrs = if raw_results.is_a?(Array)
        assert_size raw_results, 2
        raw_results
      else
        [raw_results, {}]
      end

      add_attrs = {:selected=>selected, :not_selected=>!selected}
      
      if orig.is_a?(Hash)
        orig.update add_attrs
      else
        attrs.update add_attrs
      end
    }
  end

end # === class Array


class Base_View < Mustache
  
  attr_reader :not_prefix
  
  def initialize new_app
    @app        = new_app
    @not_prefix = /^not?_/
    @cache = {}
  end

  def respond_to? raw_name
    meth         = raw_name.to_s
    
    orig         = super(meth)
    (return orig) if orig 
    
    not_meth     = meth.sub(@not_prefix, '') 
    (return super( not_meth )) if meth[@not_prefix] 
    
    orig
  end

  def method_missing *args
    meth = args.shift.to_s
    
    if meth[@not_prefix]
      result = send(meth.sub(@not_prefix, ''), *args) 
      return result_empty?(result)
    end
    
    raise(NoMethodError, "NAME: #{meth.inspect}, ARGS: #{args.inspect}")
  end

  def result_empty? result
    return result.empty? if result.respond_to?(:empty?)
    return result.zero? if result.is_a?(Fixnum)
    return result.strip.empty? if result.is_a?(String)
    !result
  end

  def development?
    The_App.development?
  end

  def development_or_test?
    The_App.development? || The_App.test?
  end

  def url
    @app.request.fullpath
  end

  def href_for obj, action = :read
    data       = obj.is_a?(Hash) ? obj : obj.data.as_hash
    case action
      when :edit
        File.join '/', data[:data_model].downcase, '/edit', data[:_id]
      when :read
        class_name = obj.is_a?(Hash) ? obj[:data_model] : obj
        case class_name 
          when News, 'News'
            filename, obj_type, *rest = data[:_id].split('-')
            File.join '/', filename, obj_type, rest.join('-'), '/' 
          when Club, 'Club'
            File.join '/', data[:filename]
          else
            raise "Unknown Class for Object: #{obj.inspect}"
        end
      else
        raise "Unknown action: #{action.inspect}"
    end
  end

  def mobile_request?
    @app.request.cookies['use_mobile_version'] && 
      @app.request.cookies['use_mobile_version'] != 'no'
  end

  def base_filename
    "#{@app.control_name}_#{@app.action_name}"
  end

  def time_i
    Time.now.utc.to_i
  end

  def css_file
    "/stylesheets/English/#{base_filename}.css"
  end

  def head_content
    ''
  end

  def loading
    nil
  end

  # === Members ===
  
  def current_member
    @app.current_member
  end

  def current_member_lives
    @cache[:current_member_lives] ||= @app.current_member.data.lives.inject([]) { |m, (k,v)| 
      m << { :filename=> k, :username=>v[:username] }
      m
    }
  end

	def current_member_lang
		current_member.data.lang
	end

  def current_member_usernames
    @cache[:current_member_usernames] ||= current_member.usernames
  end

  def single_username?
    current_member_usernames.size == 1
  end

  def single_username
    current_member_usernames.first
  end

  def multiple_usernames?
    current_member_usernames.size > 1
  end

  def multiple_usernames
    return [] if single_username?
    current_member_usernames
  end

  # === Html ===

  def auto_link str
    str.gsub(FIND_URLS, "<a href=\"\\1\">\\1</a>")
  end

  def default_javascripts
    [ {
      :src=>'/js/vendor/jquery-1.4.2.min.js' 
    },
      {:src=>"/js/pages/#{base_filename}.js"}]
  end

	def languages
		@cache[:languages] ||= begin
														 Couch_Plastic::LANGS.map { |k,v| 
															{:name=>v, :filename=>k, :selected=>(k=='en-us'), :not_selected=> (k != 'en-us')}
														 }.sort { |x,y| 
															x[:name] <=> y[:name]
														 }
													 end
	end

  def site_domain
    The_App::Options::SITE_DOMAIN
  end

  def site_url
    The_App::Options::SITE_URL
  end
  
  def js_epoch_time raw_i = nil
    i = raw_i ? raw_i.to_i : Time.now.utc.to_i
    i * 1000
  end

  def copyright_year
    [2009,Time.now.utc.year].uniq.join('-')
  end

  # === META ====

  def meta_description
  end

  def meta_keywords
  end

  def meta_cache
  end

  def javascripts
  end

  def logged_in?
    @app.logged_in?
  end

  # === FLASH MESSAGES ===

  def flash_msg?
    !!flash_msg
  end

  def flash_msg
    flash_success || flash_errors
  end

  def flash_success
    return nil if !@app.flash_msg.success?
    @flash_success ||= {:msg=>@app.flash_msg.success}
  end

  def flash_errors
    return nil if !@app.flash_msg.errors?
    errs = [@app.flash_msg.errors].flatten
    @flash_errors ||= begin
                        use_plural = errs.size > 1
                        msg = "<ul><li>" + errs.join("</li><li>") + "</li></ul>"
                        { :title  => (use_plural ? 'Errors' : 'Error'),
                          :errors => errs.map {|err| {:err=>err}}
                        }
                      end
  end

  # === NAV BAR ===
   
  def opening_msg
  end

  def site_title
    The_App::Options::SITE_TITLE
  end

  
  private # ======== 

  # From: http://www.codeism.com/archive/show/578
  def w3c_date(str_or_date)
    date = case str_or_date
    when String
      require 'time'
      Time.parse str_or_date
    when Time
      str_or_date
    end
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end

end # === Base_View

helpers {

  def dev_log_it( msg )
      puts(msg) if options.development?
  end

  def describe(c_name = nil, a_name = nil, &blok)
    if block_given?
      instance_eval( &blok  )
    else
      controller c_name if c_name
      action     a_name if a_name
    end
  end

  # Sets the following properties:
  #   :model            - Always
  #   :model_underscore - Always
  #   :controller       - Only if not set.
  def model class_obj = nil
    if class_obj
      describe_property __method_name__, class_obj
      describe_property :model_underscore, class_obj.to_s.underscore.to_sym
      if !has_property?(:controller)
        describe_property :controller, model_underscore
      end
    end
    describe_or_get_property __method_name__
  end

  # This can only bet set by used :model with an Class instance argument.
  # Example: 
  #
  # get "/news/1/" do
  #   model News
  #   ...
  # end
  #
  def model_underscore
    get_property __method_name__
  end

  def controller *args
    describe_or_get_property __method_name__, *args
  end

  def action *args
    describe_or_get_property __method_name__, *args
  end

  def doc *args
    describe_or_get_property __method_name__, *args
  end

  def reset_properties
    @props = {}
  end

  def has_property? raw_name
    @props.has_key?(raw_name)
  end

  def describe_property raw_name, value
    name = raw_name.to_sym
    @props ||= {}
    if has_property?(name)
      raise ArgumentError, "You can only set #{name.inspect} once: #{value.inspect}, #{@props.inspect}"
    end
    @props[name] = value
  end

  def get_property raw_name
    if !has_property?(raw_name)
      raise ArgumentError, "Property not set: #{raw_name.inspect}" 
    end
    @props[raw_name]
  end

  def describe_or_get_property *args
    case args.size
      when 1
        get_property *args
      when 2
        describe_property *args
      else
        raise "What?! Only 2 arguments allowed."
    end
  end
          
  def content_xml_utf8
    content_type :xml, :charset => 'utf-8'
  end

  # ==== Messages & Redirect paths =====================================

  [:success_msg, :redirect_success, :error_msg, :redirect_error].each do |meth|
    eval(%~
      def #{meth} txt = nil, &blok
         if !txt && !block_given?
            case @#{meth}
            when Proc
              instance_eval( &@#{meth} )
            else
              @#{meth}
            end
         end
         @#{meth} = txt || blok
      end

      def #{meth}? 
         !!@#{meth}
      end
    ~)
  end


  # ==== Robots ========================================================

  def valid_robots
    ['Googlebot',
     'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 4.0; obot)'
    ]
  end

  def blacklisted_robots
    ['MSIE 7.0']
  end

  def all_robots
    valid_robots + blacklisted_robots
  end

  def robot?
    return true if !env['HTTP_USER_AGENT']

    all_robots.detect { |ua|
      env['HTTP_USER_AGENT'][ua]
    }
  end

  def blacklisted_robot?
    return false if !env['HTTP_USER_AGENT']
    blacklisted_robots.detect { |ua|
      env['HTTP_USER_AGENT'][ua]
    }
  end

} # === helpers

require 'mustache'
require 'views/__Base_View_Club'
require 'views/__Base_View_Member_Life'
require 'helpers/Anchorify'

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

      add_attrs = { 
        :selected? => selected, 
        :not_selected? =>!selected
      }
      
      if orig.is_a?(Hash)
        orig.update add_attrs
      else
        attrs.update add_attrs
      end
    }
  end

end # === class Array


class Base_View < Mustache
  
  include Base_View_Club

  attr_reader :not_prefix, :app, :cache
  
  def self.delegate_template receiver, prop, value = nil
    value ||= "#{receiver}.#{prop}"
    cache_name = "#{value}_#{rand(1000)}".gsub( %r![^a-zA-Z0-9\_]!, '_' )
    %~
      def %s
        @%s ||= %s
      end
    ~ % [prop, cache_name, value].map(&:to_s)
  end
  
  def self.delegate_to receiver, *raw_words
    raw_words.flatten.each { |prop|
      class_eval(
        delegate_template(receiver, prop)
      )
    }
  end

  def self.delegate_date_to receiver, *raw_words
    raw_words.flatten.each { |prop|
      class_eval(
        delegate_template(
          receiver, 
          prop, 
          "#{receiver}.#{prop}.strftime('%b  %d, %Y')" 
        )
      )
    }
  end
  
  def initialize new_app
    @app        = new_app
    @not_prefix = /^not?_/
  end

  def compile_and_cache key, val
    cache_name = "@cache_#{key.to_s.gsub( /[^a-z0-9\_]/i , '')}".to_sym
    
    instance_variable_get(cache_name) || begin
      result = if key.to_s['clubs']
                 compile_clubs(val)
               elsif key.to_s['messages']
                 compile_messages(val)
               else
                 val
               end
      instance_variable_set( cache_name, result)
    end
  end

  def alt_method_names raw_meth
    meth = raw_meth.to_s
    [ 
      meth.sub(@not_prefix, ''),
      meth.sub(@not_prefix, '').sub('?',''),
      meth.sub('?','')
    ].compact.uniq
  end

  def find_target_method raw_meth
    meth = raw_meth.to_s
    [ 
      meth.sub(/\Anot_/, ''),            # e.g.: not_mobile_request? => 'mobile_request?'
      meth.sub(/\Ano_/, '').sub('?',''), # e.g.: no_cups? => 'cups'
      meth.sub('?','')                   # clubs? => 'clubs'
    ].compact.uniq.detect { |alt| 
        old_respond_to?(alt)
    }
  end

  def mu_respond_to? meth
    orig         = old_respond_to?(meth)
    (return meth) if orig 
    !!(alt_method_names(meth).detect { |alt| old_respond_to?(alt) })
  end
  
  alias_method :old_respond_to?, :respond_to?
  alias_method :respond_to?, :mu_respond_to?

  def method_missing meth, *args
    target = find_target_method(meth)
  
    if target
      result = send(target, *args) 
      meth_s = meth.to_s
      if meth_s[/\Ano_/] || meth_s[/\Anot_/]
        return result_empty?(result)
      else
        return !result_empty?(result)
      end
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
  
  def lang
    'en-us'
  end

  def css_file
    "/stylesheets/#{lang}/#{base_filename}.css"
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

  def current_member_lang
    current_member.data.lang
  end

  def current_member_usernames
    @cache_current_member_usernames ||= \
      if current_member
        current_member.username_hash.map { |un_id, un| 
          {:filename=>un, :username=>un, :username_id=>un_id}
        }
      else
        []
      end
  end

  def current_member_username_ids
    @cache_current_member_username_ids ||= \
        current_member ? 
          current_member_usernames.map { |doc| doc[:username_id] } :
          []
  end

  def current_member_multi_verse_menu
    @cache_current_member_multi_verse ||= current_member.multi_verse_menu
  end
  
  def single_username?
    current_member_usernames.size == 1
  end

  def first_username
    current_member.usernames.first
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

  def http_referer
    @app.env['HTTP_REFERER'].to_s.gsub("'", " ")
  end

  def include_tracking?
    @app.env['HTTP_HOST'] =~ /megauni/
  end

  def current_member_username
    @app.env['results.username']
  end
  
  def mini_nav_bar?
    false
  end

  def username_nav
    @cache_username_nav ||= begin
                                c_name = @app.control_name
                                a_name = @app.action_name
                                life_page = (c_name == :Members && a_name == 'lives')
                                current_member_usernames.map { |raw_un|
                                  un = raw_un[:username]
                                  { :selected? => (life_page && current_member_username == un), 
                                    :username=>un, 
                                    :href =>"/lives/#{un}/",
                                  :not_selected? => !(life_page && current_member_username == un)
                                  }
                                }
                              end
  end

  def compile_messages( mess_arr, parent_doc = nil )
    mess_arr.map { |doc|
      doc['href']             = "/mess/#{doc['_id']}/"
      doc['title']            = nil if not doc['title']
      doc['message_updated?'] = !!doc['updated_at']
      doc['owner_href']       = "/uni/#{doc['owner_username']}/"
      doc['owner?']           = current_member && current_member.username_ids.include?(doc['owner_id'])
      doc['not_owner?']       = !doc['owner?']
      
      if parent_doc
        doc['parent_message_owner?']     = current_member && current_member.username_ids.include?(parent_doc['owner_id'])
        doc['not_parent_message_owner?'] = !doc['parent_message_owner?']
      end

      Message::MODELS.each { |mod|
        doc["#{mod}?"]     = doc['message_model'] == mod
        doc["not_#{mod}?"] = doc['message_model'] != mod
      }

      if doc['suggest?']
        doc['accepted?'] = doc['owner_accept'] === Message::ACCEPT
        doc['not_accepted?'] = !doc['accepted?']
        
        doc['declined?'] = doc['owner_accept'] === Message::DECLINE
        doc['not_declined?'] = !doc['declined?']
        
        doc['pending?'] = doc['owner_accept'] === Message::PENDING || !doc['owner_accept']
        doc['not_pending?'] = !doc['pending?']
      end

      doc['reply-able?'] = %w{ suggest question }.include?(doc['message_model'])
      
      if doc['message_model']
        doc['message_model_in_english'] = Message::MODEL_HASH[doc['message_model']].first
        doc['message_section'] = Message::MODEL_HASH[doc['message_model']][1]
      else
        doc['message_model_in_english'] = 'unkown'
        doc['message_section'] = 'Unknown'
      end
      
      if doc['parent_message_id']
        doc['has_parent_message?'] = true
        doc['parent_message?']     = false
        doc['parent_message_href'] = "/mess/#{doc['parent_message_id']}/"
      else
        doc['has_parent_message?'] = false
        doc['parent_message?']     = true
      end
      
      doc['compiled_body'] = if from_surfer_hearts?(doc)
                               doc['body']
                             else
                               doc['body_compiled'] || auto_link(doc['body'], doc['body_images_cache'])
                             end
      doc
    }
  end

  def from_surfer_hearts?(doc)
    doc['created_at'] < '2010-01-01 01:01:01'
  end

  def auto_link raw_str, meta_img = {}
    str = raw_str.to_s 
    Anchorify.new.anchorify(str, meta_img)
  end

  def default_javascripts
    [ {
      :src=>'/js/vendor/jquery-1.4.2.min.js' 
    },
      {:src=>"/js/pages/#{base_filename}.js"}]
  end

  def languages
    @cache_languages ||= begin
                             Couch_Plastic::LANGS.map { |k,v| 
                              {:name=>v, :filename=>k, :selected? =>(k=='en-us'), :not_selected? => (k != 'en-us')}
                             }.sort { |x,y| 
                              x[:name] <=> y[:name]
                             }
                           end
  end

  def site_domain
    The_App::SITE_DOMAIN
  end

  def site_url
    The_App::SITE_URL
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
    The_App::SITE_TITLE
  end

  def site_name
    The_App::SITE_NAME
  end

  def site_tag_line
    The_App::SITE_TAG_LINE
  end

  
  private # ======== 

  def rfc822_date(str_or_date)
    date = case str_or_date
    when String
      require 'time'
      Time.parse str_or_date
    when Time
      str_or_date
    end
    date.utc.rfc2822
  end

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

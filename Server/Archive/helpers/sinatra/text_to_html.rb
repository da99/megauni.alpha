    ##########################################################
    # A collection of methods to take regular text and print
    # it as HTML.
    ##########################################################
helpers {

      #
      # Returns a UL-based string. All other text has been
      # sanitized.
      #
      def to_html_list(arr)
        vals = case arr
          when Array
            arr
          when Hash
            arr.values
          when String
            arr
          else
            ['Unknown error.']
        end
        
        case vals
          when String
            textile_to_html(vals)
          when Enumerable
            '<ul><li>' + 
              vals.map { |s| 
                          titleize(Wash.html(s))
              }.join("\n</li><li>") + 
            "</li></ul>"
        end
        # '* ' + vals.map {|s| Wash.html(s).capitalize }.join("\n")
      end

      # Returns String, but with first non-whitespace 
      # character upcased. Original whitespace on
      # both sides of string are left intact.
      def titleize(s)
        first_char = s.lstrip[0,1]
        s.sub( first_char, first_char.upcase )
      end

      # =========================================================
      # Take newlines (regardless of Windows or Unix), and
      # convert them to <br />
      # =========================================================
      def to_nbsp(txt, nbsp_type = 'br /')
        txt.gsub(/\r\n|\n|\&\#10\;/, "<#{nbsp_type.strip}>")
      end
      
      # =========================================================
      # Grabs all emails from text and turns them into mailto: anchor tags.
      # =========================================================
      def emails_to_mailtos(txt)
        txt.gsub('&#64;', '@').gsub( Member::EMAIL_FINDER ) { |match| "<a href=\"mailto:#{match}\">#{match}</a>"}
      end  
      
      # =========================================================
      # Create an :href to be used in an anchor tag. The :href string
      # returned contains a subject and body.
      # Uses the format of:
      #   mailto:?subject=new%20subject&body=new%20body.
      # Uses URI.escape.
      # =========================================================
      def href_mailto(subject, body)
        "mailto:?subject=#{URI.escape(subject)}&body=#{URI.escape(body)}"
      end  
      
      # =========================================================
      # Parameters:
      #  filename = Page filename, usually @page_filename. 
      #                    ".js?r=#{ time string}" is automatically added to end.
      #                    The time string is set to the second or to ToHTML::TIME_STAMP_FOR_FILES, 
      #                    depending on BusyConfig.development?
      #  options         = Optional Hash for SCRIPT tag attributes. E.g. { :defer=>"true" }
      #                    Also allows :dont_timestamp if you do not want to add "?r=TIMESTAMP" to end of file.
      #                    :dont_timestamp is NOT added to SCRIPT tag attributes.
      # =========================================================
      def script_tag(filename, opts = {})
        @timestamp    ||= options.development? ? 
                                            Time.now.utc.strftime( '%Y-%m-%d-%H-%M-%S' ) :
                                            Time.now.utc.strftime( '%Y-%m-%d-%H' ) ;
                                            
        
        # Delete unwanted options to prevent them from being put in the SCRIPT tag attributes list.
        timestamp     = opts.delete(:dont_timestamp) ? '' : "?r=#{@timestamp}"
        
        # Turn :options into a STRING list of SCRIPT tag attributes
        options_str   = opts.inject('') { |m , pair | m << " #{pair.first}=\"#{pair.last}\" "; m }
        
        # Find full path to file.
        is_local_file = File.basename( filename ) == filename
        
        full_filepath =  is_local_file ? 
                            "/js/pages/#{filename}" :
                            filename
        
        # Now send the results as a STRING.
        "<script type=\"text/javascript\" src=\"#{full_filepath}#{timestamp}\" #{options_str}></script>"
      end

      
}

__END__



module Ramaze::Helper::HTML

  def find_template_filename_on_disk_or_inline(raw_filename)
    orig_filename = Wash.filename( raw_filename )

    filename = [ "#{orig_filename}.sass" , "#{orig_filename}.haml", orig_filename].detect { |fn| 
                          Sinatra.application.templates.has_key?( fn.to_sym ) 
               } || orig_filename
    
  end
  
  def escape_haml(raw_name = nil, options={})
    name = raw_name || (@page_filename && @page_filename.to_sym) || nil
    raise ArguementError, ":raw_name and @page_filename are undefined." unless name
    
    haml(name, options.merge({:options=>{:attr_wrapper=>'  "  '.strip, :escape_html=>true}}))
  end
  
  def cache_content(path, content)
    return content unless production?
    DiskFile.create( :path=>path, :content => content )    
    content
  end

  def partial(name, options={})
    escape_haml( name, options.merge(:layout => false) )
  end 
  
  def radio_attrs(name, value, selected_value )
    
    { :type=>'radio', 
      :name=>name, 
      :value=>value,
      :checked=>( value.eql?(selected_value) ? :checked : nil )
    }
  end

end # Ramaze::Helper::HTML

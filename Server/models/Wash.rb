# === Important Gems ===
# require 'multibyte'
require 'cgi' # Don't use URI.escape because it does not escape all invalid characters.
require 'htmlentities'
require 'loofah'

# ===============================================
# A collection of methods to sanitize text.
# ===============================================
class Wash

  # HTML_ESCAPE_TABLE is used after text is escaped to
  # further escape text more.  This is why th semi-colon (&#59;) was left out 
  # from HTML_ESCAPE_TABLE. It would conflict with already escaped text.
  # For more entities: http://www.w3.org/MarkUp/html3/latin1.html
  # or go to: http://www.mountaindragon.com/html/iso.htm
  HTML_ESCAPE_TABLE = {
  
    '&laquo;' => "&lt;",
    '&raquo;' => "&gt;",
    
    "&lsquo;" => "&apos;",
    "&rsquo;" => "&apos;",
    "&sbquo;" => "&apos;",
    
    "&lsquo;" => "&apos;",
    "&rsquo;" => "&apos;",
    
    "&ldquo;" => "&quot;",
    "&rdquo;" => "&quot;",
    "&bdquo;" => "&quot;",  
    
    "&lsaquo;" => "&lt;",
    "&rsaquo;" => "&gt;",
    
    "&acute;" => "&apos;",
    "&uml;"   => "&quot;",
    
    '\\' => "&#92;",
    # '/'  => "&#47;",
    # '%' => "&#37;",
    # ':' => '&#58;',
    # '=' => '&#61;',
    # '?' => '&#63;',
    # '@' => '&#64;', 
    "\`" => '&apos;',
    '‘' => "&apos;",
    '’' => "&apos;",
    '“' => '&quot;',
    '”' => '&quot;',
    # "$" => "&#36;",
    # '#' => '&#35;', # Don't use this or else it will ruin all other entities.
    # '&' => # Don't use this "    "    "  " " "
    # ';' => # Don't use this "    "    "   " " "
    '|' => '&brvbar;',
    '~' => '&sim;'
    # '!' => '&#33;',
    # '*' => '&lowast;', # Don't use this. '*' is used by text formating, ie RedCloth, etc.
    # '{' => '&#123;',
    # '}' => '&#125;',
    # '(' => '&#40;',
    # ')' => '&#41;',
    # "\n" => '<br />'
  }

  def self.language( raw_filename )
    no_chars = '<>\\/\\\\|[]{}~!@\\#\\?$%^^&*()-=+_\\`.,\\\"'
    safe_filename = raw_filename.multibyte_chars.gsub(/[#{Regexp.escape(no_chars)}]+/, ' ERROR ').strip
    
    safe_filename
  end    

  # ===============================================
  def self.column_key( str )
    plaintext( str ).strip.upcase.gsub(/[[:space:]]{1,}/, ' ')
  end

  # ===============================================
  #   Raises: TZInfo::InvalidTimezoneIdentifier.
  # ===============================================
  def self.validate_timezone(timezone)
    TZInfo::Timezone.get( timezone.to_s.strip ).identifier
  end
  
  # =========================================================
  # Takes out any periods and back slashes  in a String.
  # Single periods surround text  are allowed on the last substring 
  # past the last slash because they are assumed to be filenames 
  # with extensions.
  # =========================================================
  def self.path( raw_path )
    clean_crumbs        = raw_path.split('/').map { |crumb| Wash.filename(crumb) }
    File.join( *clean_crumbs )    
  end  
  
  
  # ====================================================================
  # Returns a String where all characters except:
  # letters  numbers underscores dashes
  # are replaced with a dash.
  # It also delets any non-alphanumeric characters at the end
  # of the String.
  # ====================================================================
  def self.filename( raw_filename )
    semi_safe_filename = plaintext( raw_filename ).downcase
    
    @filename_washers ||= [
                            [ /\.{1,}/, '.' ] ,             # get rid of repeating dots
                            [ /[^a-z0-9\_\.]{1,}/i, '-' ] , # replace invalid chars with a dash
                            [ /[^a-z0-9]{1,}\Z/, '' ]       # delete ending non alphanum 
                          ]
    filename = @filename_washers.inject( semi_safe_filename.multibyte_chars ) { |memo, pair|
      memo.gsub(pair[0], pair[1])
    }
    
    filename.to_s
  end



  
  # ===============================================
  def self.is_a_valid_column_key_name?( key_name )
      short_enough = key_name.strip.size <= 40
      is_number = true
      begin
        Float(key_name)
      rescue ArgumentError
        is_number = false
      end
      short_enough && !is_number
  end

  # ===============================================
  
  # ===============================================
  # This method is not meant to be called directly. Instead, call
  # <Wash.parse_tags>.
  # Returns: String with 
  #      * all spaces and underscores turned into dashes.
  #      * all non-alphanumeric characters, underscores, dashes, and periods
  #        turned into dashes.
  #      * non-alphanumeric characters at the beginning and end stripped out.
  # ===============================================
  def self.tag( raw_tag )
    # raw_tag.strip.downcase.gsub( /[^a-z0-9\.]{1,}/,'-').gsub(/^[^a-z0-9]{1,}|[^a-z0-9]{1,}$/i, '').gsub(/\.{1,}/, '.')
    raw_tag.strip.downcase.gsub(/^[\,\.]{1,}|[\"]{1,}|[\,\.]{1,}$/, '').gsub(/\ /, '-')
  end    

  # ===============================================
  

  
  # ===============================================
  def self.validate_twitter_username(raw_name)
    valid_twitter_username_chars   = /\A[a-z0-9\_]{1,100}\Z/i
    # String-ify
    # Strip
    # Replace any @ symbols
    username = raw_name.to_s.strip.gsub(/\A\@+|\@+\Z/, '')
    
    raise ERRORS::InvalidTwitterUsername, "Username format invalid: #{username}" unless username =~ valid_twitter_username_chars
    
    username
  end  
  
  def self.url_escape txt
    CGI.escape(txt)
  end

  # ===============================================
  # A better alternative than "Rack::Utils.escape_html". Escapes
  # various characters (including '&', '<', '>', and both quotation mark types)
  # to HTML decimal entities. Also escapes the characters from
  # SWISS::HTML_ESCAPE_TABLE.
  #
  # Text has to be UTF-8 before encoding, according to HTMLEntities gem.
  # Therefore, all text is run through <Wash.plaintext> before encoding.
  # ===============================================
  def self.html( raw_text )
    
    # Turn string into UTF8. (This also takes out control characters 
    # which is good or else they too will be escaped into HTML too.
    # Strip it after conversion.
    utf8_text = plaintext(raw_text).strip
    # return Dryopteris.sanitize(utf8_text)
    # Now encode it.
    coder = HTMLEntities.new
    encoded_text = coder.encode( coder.decode(utf8_text), :named )
        
    # Encode a few other symbols.
    # This also normalizes certain quotation and apostrophe HTML entities.
    normalized_encoded_text = HTML_ESCAPE_TABLE.inject(encoded_text) do |m, kv|
       m.gsub( kv.first, kv.last)
    end
    
    sanitized_text = Loofah.scrub_fragment( normalized_encoded_text, :prune ).to_s
  end # === def self.html
 
  
  # ===============================================
  # Returns: A string that is:
  #        * normalized to :KC
  #        * "\r\n" changed to "\n"
  #        * all control characters stripped except for "\n"
  #        * all control characters (including \n, \r) stripped at the beginning
  #          and end.
  # Options:
  #    :tabs
  #    :spaces
  #
  # ===============================================
  def self.plaintext( raw_str, *opts)
    return nil unless  raw_str

    # Check options.
    @plaintext_allowed_options ||= [ :spaces, :tabs ]
    invalid_opts = opts - @plaintext_allowed_options
    raise(ArgumentError, "INVALID OPTION: #{invalid_opts.inspect}" )  if !invalid_opts.empty?

    # Save tabs if requested.
    raw_str = raw_str.gsub("\t", "&#09;") if opts.include?(:tabs)
    
    # First: Normalize characters.
    # Second: Strip out control characters.
    # Note: Must be normalized first, then strip. 
    # See: http://msdn.microsoft.com/en-us/library/ms776393(VS.85).aspx    
    final_str = raw_str.split("\n").map { |line| 
                        line.chars.normalize.gsub( /[[:cntrl:]\x00-\x1f]*/, '' ) 
                        # Don't use "\x20" because that is the space character.
                    }.join("\n")

    # Save whitespace or strip.
    if !opts.include?(:spaces)
        final_str = final_str.strip
    end
  
    # Normalize quotations and other characters through HTML entity encoding/decoding.
    coder = HTMLEntities.new
    normalised_str = HTML_ESCAPE_TABLE.inject(coder.encode( final_str, :named )) do |m, kv|
       m.gsub( kv.first, kv.last)
    end    
    final_str = coder.decode( normalised_str  )

    # Put back tabs by request.
    if opts.include?(:tabs)
        final_str = final_str.gsub("&#09;", "\t") 
    end

    final_str
    
  end # self.plaintext


end # === Wash

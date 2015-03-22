require 'sanitize'

class Anchorify
  
  class << self
    attr_accessor :last_filter_added
    attr_reader :filters, :filter_order
  end

  attr_accessor :filters

  def self.filters
    @filters ||= {}
  end

  def self.filter_order
    @filter_order ||= []
  end

  def self.add_filter name , &blok
    self.filter_order << name
    self.filters[name] ||= {}
    self.filters[name][:options] ||= {}
    self.filters[name][:block] = blok
    self.last_filter_added = filters[name]
    self
  end

  def self.with( opts = {}, &blok )
    last_filter_added[:options].update(opts)
    if block_given?
      last_filter_added[:block]=blok
    end
    self
  end

  def initialize *filters
    @filters = begin
                 if filters.empty?
                   self.class.filter_order
                 else
                   new_filters = filters.compact.uniq
                   invalid_filters = new_filters - filters.keys
                   raise ArgumentError, "Invalid filter names: #{invalid_filters.inspect}"
                   new_filters 
                 end
               end
  end

  def anchorify raw_txt, raw_meta = nil
    txt = raw_txt.to_s.strip
    return '' if !txt || txt.empty?
    meta = (raw_meta || []).inject({}) { |memo, val|
      memo[val.first] = {:width=>val[1], :height=>val[2]}
      memo
    }
    filters.inject(txt) { |memo, fil|
      
      the_filter = Anchorify.filters[fil]
      
      case the_filter[:block].arity
      when 1
        the_filter[:block].call memo
      else
        opts = the_filter[:options].empty? ? meta : the_filter[:options]
        the_filter[:block].call memo, opts
      end
      
    }
  end

end # === class


AutoHtml = Anchorify

Anchorify.add_filter(:br_ify) do |txt|
  txt.gsub(/\r?\n/, "<br />")
end

Anchorify.add_filter(:scrubber) do |txt|
  relax = Sanitize::Config::RELAXED
  relax[:attributes]['object'] = %w{ width height }
  relax[:elements] << 'object'
  
  relax[:attributes]['param'] = %w{ name value }
  relax[:elements] << 'param'
  Sanitize.clean(txt, relax)
end

Anchorify.add_filter(:image) do |text, options|
  new_text = " #{text} ".gsub(/https?:\/\/[^\s]+(jpg|jpeg|bmp|gif|png)(\?\S+)?/i) do |match|
    dims   = options[match] || {}
    width  = (dims['width'] || dims[:width]).to_i
    height = (dims['height'] || dims[:height]).to_i
    if !(width.zero? && height.zero?)
      %|<img src="#{match}" width="#{width}" height="#{height}" alt="*"/>|
    else
      %|<img src="#{match}" alt="*"/>|
    end
  end
  new_text.strip
end


%w{ dailymotion google_video vimeo }.each { |filter|
  require "auto_html/filters/#{filter}"
}

Anchorify.add_filter(:youtube).with(:width => 390, :height => 250) do |text, options|
  text.gsub(/http:\/\/(www.)?youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)(\&\S+)?/) do
    youtube_id = $2
    %{
      <object width="#{options[:width]}" height="#{options[:height]}" type="application/x-shockwave-flash" data="http://www.youtube.com/v/#{youtube_id}" >
        <param name="allowFullScreen" value="true" />
        <param name="movie" value="http://www.youtube.com/v/#{youtube_id}" />
        <param name="wmode" value="transparent" />
      </object>
    }
  end
end

Anchorify.add_filter(:link) do |text|
  find_urls = %r~(\s|<br />|<br/>)(http://[^\/]{1}[A-Za-z0-9\@\#\&\/\-\_\?;\=\.%]+)(\s|<br />|<br/>)~
  (' ' + text + ' ').gsub(find_urls) { |entire_match|
    %!#{$1}<a href="#{$2}">#{$2}</a>#{$3}!
  }.strip
end


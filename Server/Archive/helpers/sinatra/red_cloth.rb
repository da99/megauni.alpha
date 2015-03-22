

require 'RedCloth'
configure do
  module ImgTag
    def img( opts )

      html_attrs = ''

      # Add src
      attrs = opts[:text].gsub('<br />', '').strip.split("\n").map {|c| c.strip }
      html_attrs = " src=\"#{attrs.shift.split('<').first.strip}\" "


      [ attrs.shift, attrs.shift ].compact.each do |a|
        matches = a.scan( /(w|h)\ +([0-9px]+)/i )
        if matches.empty? # Add alt text 
          html_attrs += " alt=\"#{a}\"  title=\"#{a}\" "
        else # Add Width and Height dimensions, if any.
          matches.each do |d, q|
            a = ( d.downcase == 'w' ? 'width' : 'height' )
            html_attrs += " #{a}=\"#{q.to_i}\" "
          end
        end
      end

      # Add default alt/title attributes if none were found.
      html_attrs += ' alt="*" title="*" ' if !html_attrs['alt=']

      # Add other options.
      [:class, :id].each do |a|
        html_attrs += " #{a}=\"#{opts[a]}\"" if opts[a]
      end

      html = "<img #{html_attrs} /> \n "
    end
  end # === module

end # === configure

helpers {

  def textile_to_html(txt)
    r = RedCloth.new(txt.strip)
    r.extend ImgTag
    r.filter_html = true
    r.to_html
  end

  def news_to_html post, field
    if post.last_modified_at < Time.utc(2009, 9, 17)
      post.data.send field
    else
      textile_to_html( post.data.send(field) )
    end
  end
} # === helpers


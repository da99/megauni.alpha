module MappingExtension
  def img(opts)
    html  = %Q{<img src="text" alt="#{opts[:text]}" />\n}
    opts.inspect
  end
end

require 'rubygems'
require 'redcloth'

text = %~
p.  The next line will contain a map:

img. 
  /somet/path
  Hello!
~
r = RedCloth.new text
r.extend MappingExtension

puts r.to_html

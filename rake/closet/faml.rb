class Faml < Thor
  include Thor::Sandbox::CoreFuncs
  TAB_SPACES = 2



  desc :compile, "Turn all files in /../compiled into HTML web.py templates."
  def compile
    Dir['**/compiled'].each do |compiled_dir|

      dir   = Pow( File.dirname( compiled_dir )  )
      c_dir = Pow( compiled_dir )

      # raise "#{dir} does not exist." if !dir.directory?
      # shout(capture_all('mkdir %s' % c_dir.to_s.inspect)) if !c_dir.directory?

      dir.each { |f|
        if f.file? && f.to_s =~ /\.faml\.rb\z/
          content  = compile_file(f)
          dirname  = File.dirname(f.to_s)
          filename = File.basename(f.to_s).sub(/\.faml\.rb\z/,'.html')
          Pow( c_dir,  filename ).create do |s|
            s.puts content
          end
        end
      }
    end
  end

  private # ================================================================

  attr_accessor :compiled_layout_content

  def compile_file(raw_file_name)
    divider = '__START__'

    fn = raw_file_name.is_a?(Pow::File) ? raw_file_name : Pow(raw_file_name.to_s)
    starts = fn.read.split( divider)

    python = ''
    add_layout = !( File.basename(fn.to_s) =~ /^_/ || fn.to_s =~ /layout.faml.rb\z/ )

    faml = if starts.size == 1
      starts.pop
    else
      python = starts.shift
      starts.join('__START__')
    end



    lines = faml.lstrip.gsub("\t", ' ' * TAB_SPACES).split("\n")
    new_tag = /^[\ ]{0,}[A-Z\_0-9\-]{1,}\:/
    tags = []
    last_max = 0
    lines.each { |l|
      pieces = l.split(':')
      # SPACES, TAG, ATTRIBUTES, CONTENT
      if l =~ new_tag
        spaces = (l =~ /^(\ {0,})/ && $1.size)
        tags << { :spaces => spaces ,
        :tag => pieces.shift.strip,
        :attrs => pieces.join(':'),
        :content => "" }
        if spaces < last_max

        else

        end
        last_max = spaces
      else
        if tags.empty?
          tags.unshift( {:spaces=>0, :tag=>'NO_TAG', :attrs=>'', :content=>''} )
        end
        tags.last[:content] += ( "\n" + l )
      end
    }

    if !add_layout
      python + compile_tags( tags )
    else
      layout_file = Pow( File.dirname(fn.to_s), 'layout.faml.rb')
      if layout_file.file?
        self.compiled_layout_content ||= compile_file(layout_file)
        python + self.compiled_layout_content.sub('%CONTENT%', compile_tags(tags) )
      end
    end

  end



  def compile_tags( tags )
    raise ArgumentError, "Invalid tags: #{tags.inspect}" if !tags
    return "" if tags.empty?
    open_tags = []

    t = tags.shift

    indent =  " " * t[:spaces]
    attrs = (" " + t[:attrs].to_s )
    attrs = '' if attrs.strip.empty?
    self_closing = ['META', 'BR', 'INPUT', 'LINK'].include?(t[:tag].upcase)
    end_tag = self_closing ? " />" : "</#{t[:tag]}>"
    if t[:tag] == 'NO_TAG'
      return indent + "#{t[:content]}\n#{indent}#{compile_tags(tags)}"
    end
    return indent + "<#{t[:tag]} #{attrs} />\n#{t[:content]}\n#{indent}#{compile_tags(tags)}" if self_closing
    if tags.empty?
      content = "<#{t[:tag]}#{attrs}>\n#{t[:content]}\n#{indent}#{end_tag}"

    elsif tags.first[:spaces] == t[:spaces]
      content = "<#{t[:tag]}#{attrs}>\n#{t[:content]}\n#{indent}#{end_tag}\n#{compile_tags(tags)}"

    elsif tags.first[:spaces] > t[:spaces]
      content = "<#{t[:tag]}#{attrs}>\n#{t[:content]}\n#{compile_tags(tags)}\n#{indent}#{end_tag}\n#{compile_tags(tags)}"

    elsif tags.first[:spaces] < t[:spaces]
      content = "<#{t[:tag]}#{attrs}>\n#{t[:content]}\n#{indent}#{end_tag}"

    end

    indent + content
  end


end # === Faml


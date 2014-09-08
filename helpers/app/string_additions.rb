__END__
class String

  def strip_slashes
    strip.gsub(/\A\/|\/\Z/, '')
  end

  def to_time
    return nil unless self =~ /\d{4}-\d{2}-\d{2}\ \d{2}:\d{2}:\d{2}/
    pieces = split(' ')
    year, month, day = pieces.first.split('-')
    hour, mins, secs = pieces.last.split(':')
    Time.utc year, month, day, hour, mins, secs
  end

  def must_not_be_empty
    raise ArgumentError, "String can't be empty." if strip.empty?
    strip
  end

  def must_exist_on_file_system
    return true if File.symlink?(expand_path)
    return true if File.exists?(expand_path)
    raise ArgumentError, "Does not exist: #{expand_path.inspect}"
  end

  def has_extension? s_or_sym
    ext = '.' + s_or_sym.to_s.must_not_be_empty.sub(/^\.+/, '')
    !!must_not_be_empty[/#{Regexp.escape(ext)}\z/]
  end

  def replace_extension s_or_sym
    ext       = '.' + s_or_sym.to_s.must_not_be_empty.sub(/^\.+/, '')
    base_name = File.basename(must_not_be_empty)
    pieces    = base_name.split('.')
    case pieces.size
      when 1
        self + ext
      else
        pieces.pop
        self.sub(/#{Regexp.escape(base_name)}\z/, pieces.join('.') + ext)
    end
  end

end # === String



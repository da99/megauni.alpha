class FiDi

  def self.validate_path file_sys_name
    name = file_sys_name.to_s.strip
    raise ArgumentError, "String can't be empty." if name.empty?
    name
  end

  def self.must_exist raw_name
    name = validate_path(raw_name)
    return true if File.symlink?(name)
    return true if File.exists?(name)
    raise ArgumentError, "Does not exist: #{name.inspect}"
  end

  def self.move_to_trash raw_name
    name = validate_path raw_name
    must_exist name
    system("mv -i #{name.inspect} ~/.local/share/Trash/files ")
  end

  def self.file_system_name raw_name
    validate_path( File.expand_path(raw_name) )
  end

  def self.directory_name raw_name
    FiDi_Directory.new(raw_name)
  end

  def self.directory *raw_name
    FiDi_Directory.new *raw_name
  end
                          
  def self.file *raw_name
    FiDi_File.new( *raw_name )
  end

end # === String

class FiDi_Directory

  attr_reader :path
  
  def initialize *raw_str
    orig_path = File.expand_path(FiDi.validate_path(File.join(*raw_str)))
    if File.exists?(orig_path)
      if not File.directory?(orig_path)
        raise ArgumentError, "Directory path exists, but is not a directory: #{orig_path}"
      end
    end
    @path = orig_path
  end

  def mkdir
    if not File.exists?(path)
      Dir.mkdir(path)
      return path
    end

    if File.directory?(path)
      return path
    end

    raise ArgumentError, "Path already exists, but is not a directory: #{path}"
  end

  def copy_to(raw_path)

    # Rsync creates the folder of the original into the target folder.
    # Example: /BACKUP -> /TARGET ==> /TARGET/BACKUP
    # To get around this, we use the parent folder of the target.
    target = FiDi.directory(raw_path).up 
    final_path = File.join(target.path, File.basename(path))
    final_path_exists = File.exists?(final_path)
    raise ArgumentError, "Path already exists: #{target.path}" if final_path_exists

    rsync_installed = `which rsync`['rsync']
    if !rsync_installed 
      raise ArgumentError, "Rsync is not installed."
    end
    puts `rsync -av #{path} #{target.path}`
    target
  end

  def name 
    File.basename(path)
  end
  
  def exists?
    File.exists?(path)
  end

  def up *args
    FiDi_Directory.new( File.expand_path(File.join(path, '..', *args)) )
  end

  def down *args
    raise ArgumentError, "Unable to continue w/o arguments: #{args.inspect}" if args.empty?
    FiDi_Directory.new( File.expand_path(File.join(path, *args)) )
  end
  
  def each_file &blok
    return nil if !File.directory?(path)
    raise ArgumentError, "Block is needed." unless block_given?
    Dir.entries(path).each { |file_name|
      file_path = File.expand_path(File.join(path, file_name))
      blok.call(file_path) if File.file?(file_path)
    }
  end
  
  def create_alias *args
    new_dir = File.expand_path(File.join(*args))
    is_symlink = File.symlink?(new_dir)
    identical = (File.exists?(new_dir) && File.identical?(path, new_dir)) ||
                (is_symlink && File.readlink(new_dir) === path)
    return new_dir if identical

    if File.exists?(new_dir)
      raise ArgumentError, "Already exists: #{new_dir.inspect}"
    end
    File.symlink(path, new_dir)
    FiDi.directory(new_dir)
  end

  def ruby_files_wo_rb
    ruby_files false
  end

  def ruby_files w_extension = true
    
    Dir.entries(path).map { |file_name| 
        if file_name =~ /\.rb\z/
          full_path = File.expand_path(File.join(path,file_name))
          w_extension ?
            full_path :
            full_path.sub(/\.rb\z/i, '') 
        else
          nil
        end
      }.compact
    
  end  
  
  def relative *args
    File.join(path, *args).expand_path
  end
  
end # ======== FiDi_Directory

class FiDi_File

  attr_reader :path

  def initialize *raw_name
    orig_path = File.expand_path(FiDi.validate_path(File.join(*raw_name)))
    if File.directory?(orig_path)
      raise ArgumentError, "Already a directory: #{orig_path.inspect}"
    end
    @path = orig_path
  end

  def must_exist
    return true if File.file?(path)
    raise ArgumentError, "Path is not a file: #{path}"
  end

  def must_not_exist
    return true if not File.exists?(path)
    raise ArgumentError, "Path already exists: #{path}"
  end

  def write content
    must_not_exist
    File.open(path, 'w') do |file|
      file.write content
    end
  end

  def exists?
    File.exists?(path)
  end  
  
  def name
    File.basename(path)
  end

  def directory
    FiDi.directory(dirname)
  end

  def dirname
    File.dirname(path)
  end

  def read
    File.read(path)
  end
  
  def rename_to file_name_or_path
    f_path = if File.basename(file_name_or_path) == file_name_or_path
               File.join(File.dirname(path), file_name_or_path)
             else
               File.expand_path(file_name_or_path)
             end
    if File.exists?(f_path) 
      if File.identical?(f_path, path)
        return f_path
      else
        raise ArgumentError, "File already exists: #{f_path.inspect}"
      end
    end
    File.rename path, f_path
    f_path
  end
  
  def create_alias *args
    new_file = File.expand_path(File.join(*args))
    return new_file if File.exists?(new_file) && File.identical?(path, new_file)
    if File.exists?(new_file)
      raise ArgumentError, "File already exists: #{new_file.inspect}"
    end
    File.symlink(path, new_file)
    new_file
  end

  def relative *args
    File.join(path, '..', *args).expand_path
  end

end # ======== FiDi_File

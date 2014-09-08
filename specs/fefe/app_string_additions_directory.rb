
class App_String_Additions_Directory
  
  include FeFe_Test

  context 'Test Directory properties of String Additions.'

  before {
    @real_dir_path = File.dirname(File.expand_path(__FILE__))
    @delete_files = []
  }

  after {
    @delete_files.each { |raw_file|
      file = raw_file.expand_path
      if file['Desktop']
        file.move_to_trash
      end
    }
  }

  it 'returns true if String is an existing dir and you ask :directory?' do
    demand_equal( true, '~/'.directory? )
  end

  it 'returns false if you ask :directory? and String is not an existing directory' do
    demand_equal( false, '~/zzzzzzz'.directory? )
  end

  it 'returns false if you ask :directory? and String is of an existing file.' do
    home_dir  = File.expand_path('~/')
    file_name = Dir.entries(home_dir).detect { |un|
                  File.file? File.join(home_dir,un) 
                }
    file_path = File.expand_path(File.join('~/', file_name))
    demand_equal( false, file_path.directory? )
  end

  it 'returns false if you ask :directory? and String is of a non-existent file.' do
    file_path = File.expand_path('~/random_file_1234.435.rb')
    demand_equal(false, file_path.directory?)
  end

  it 'gives you basename of directory path' do
    demand_equal(
      File.basename(@real_dir_path),
      @real_dir_path.directory.name
    )
  end

  it 'gives you the original path, expanded' do
    demand_equal(
      File.expand_path(@real_dir_path),
      @real_dir_path.directory.path
    )
  end

  it 'returns true if directory exists.' do
    demand_equal(
      true,
      '~/'.directory.exists?
    )
  end

  it 'gives you full path to parent directory' do
    path = File.dirname(File.expand_path(__FILE__))
    demand_equal(
      File.dirname(path),
      path.directory.up
    )
  end

  it 'gives you full path to a child directory' do
    sub_dir = @real_dir_path.split('/').reverse[0,2].reverse.join('/')
    demand_equal(
      @real_dir_path,
      @real_dir_path.directory.up.directory.up.directory.down(sub_dir)
    )
  end

  it 'iterates each expanded file path in an existing directory' do
    orig_files = Dir.entries(@real_dir_path).map { |name|
      new_file = File.join(@real_dir_path, name)
      File.file?(new_file) ?
        new_file :
        nil
    }.compact
    
    new_files = []
    @real_dir_path.directory.each_file do |file_path|
      new_files << file_path
    end
    
    demand_equal orig_files, new_files
  end

  it 'gives you the expanded path of each ruby file in a directory' do
    ruby_files = Dir.entries(@real_dir_path).select { |name|
      name =~ /\.rb\z/
    }.map { |name| File.join(@real_dir_path, name) }

    demand_equal ruby_files, @real_dir_path.directory.ruby_files
  end

  it 'gives you the expanded path without .rb extension of each ruby file.' do
    ruby_files = Dir.entries(@real_dir_path).select { |name|
      name =~ /\.rb\z/
    }.map { |name| File.join(@real_dir_path, name.sub(/\.rb$/, '') ) }

    demand_equal ruby_files, @real_dir_path.directory.ruby_files_wo_rb
  end

  it 'gives you access to files in the directory.' do
    dir            = File.dirname(File.expand_path(__FILE__))
    orig_file_name = Dir.entries(dir).detect { |name|
      File.file?(File.join(dir, name))
    }
    orig_file      = File.expand_path(File.join(dir, orig_file_name))
    
    demand_equal orig_file, __FILE__.file.directory.relative( orig_file_name)
  end

  it 'gives you access to files in parent directories.' do
    dir            = File.dirname(File.expand_path(__FILE__+'/'+'../../') )
    orig_file_name = Dir.entries(dir).detect { |name|
      File.file?(File.join(dir, name))
    }
    orig_file      = File.expand_path( File.join(dir, orig_file_name))
    
    demand_equal orig_file, __FILE__.file.directory.relative( '../../', orig_file_name)
  end
  
  context ':create_alias' 

  it 'creates a symbolic link to a directory' do
    @delete_files << (o_dir = "~/Desktop/dir_#{Time.now.to_i}".expand_path)
    @delete_files << (l_dir = "~/Desktop/dir_linked_#{Time.now.to_i}".expand_path)

    system("mkdir #{o_dir.inspect}")
    o_dir.directory.create_alias l_dir
    demand_equal( true, File.identical?(o_dir, l_dir) )
    demand_equal( true, File.symlink?(l_dir) )
  end

  it 'raises ArgumentError if directory already exists for symbolic link' do
    @delete_files << (o_dir = "~/Desktop/dir_e_#{Time.now.to_i}".expand_path)
    @delete_files << (l_dir = "~/Desktop/dir_d_#{Time.now.to_i}".expand_path)

    system("mkdir #{o_dir.inspect}")
    system("mkdir #{l_dir.inspect}")

    err = begin
      o_dir.directory.create_alias(l_dir)
    rescue ArgumentError => e
      e
    end

    demand_equal( "Already exists: #{l_dir.inspect}", err.message)
  end

  it 'raises ArgumentError if file already exists for symbolic link' do
    @delete_files << (o_dir = "~/Desktop/dir_______#{rand(200)}".expand_path)
    @delete_files << (l_dir = "~/Desktop/file__#{Time.now.to_i}".expand_path)

    system("mkdir #{o_dir.inspect}")
    system("echo \"test\" > #{l_dir.inspect}")

    err = begin
      o_dir.directory.create_alias(l_dir)
    rescue ArgumentError => e
      e
    end

    demand_equal( "Already exists: #{l_dir.inspect}", err.message)
  end

end

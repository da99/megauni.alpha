
class App_String_Additions_File
  
  include FeFe_Test

  context 'Test File properties of String Additions.'

  before {
    @path = '~/megauni/config.ru'
    @delete_files = []
  }

  after {
    @delete_files.each { |file|
      file_path = File.expand_path(file.to_s)
      if File.file?(file_path) || File.symlink?(file_path)
        File.delete(file_path)
      end
    }
  }
  
  it 'lets you ask: file?' do
    demand_equal true, @path.file? 
  end
  
  it 'lets you ask: file.exists?' do
    demand_equal true, @path.file.exists? 
  end
  
  it 'expands name of file' do
    demand_equal(
      File.expand_path(@path),
      @path.file.expand_path
    )
  end

  it 'gives the file name without path' do
    demand_equal(
      File.basename(@path),
      @path.file.name
    )
  end

  it 'gives the expanded path of file' do
    demand_equal(
      File.expand_path(@path),
      @path.file.path
    )
  end
  
  it 'reads the file' do
    demand_equal(
      File.read(File.expand_path(@path)),
      @path.file.read
    )
  end
  
  it 'renames file' do
    @delete_files << (old_file = File.expand_path( '~/Desktop/s123456'+Time.now.utc.to_i.to_s+'.rb' ))
    @delete_files << (new_file = File.expand_path('~/Desktop/s_new_123456' + Time.now.utc.to_i.to_s + '.rb'))
    
    system("echo 'test 123' > #{old_file}")
    old_file.file.rename_to(new_file)
    demand_equal(
      true,
      File.file?(new_file)
    )
  end

  it 'raises an error if new file name already exists and is non-identical.' do
    @delete_files << (old_file = File.expand_path( '~/Desktop/s123456'+Time.now.utc.to_i.to_s+'.rb' ))
    @delete_files << (new_file = File.expand_path('~/Desktop/s_new_123456' + Time.now.utc.to_i.to_s + '.rb'))
    
    system(%!echo "12354" > #{old_file}!)
    system(%!echo "567"   > #{new_file}!)
    
    e = begin
      old_file.file.rename_to(new_file)
    rescue ArgumentError => err
      err
    end
    
    demand_equal( "File already exists: #{new_file.inspect}", e.message )
  end

  context 'Creating symbolic links with :create_alias'

  it 'uses relative paths' do
    @delete_files << (old_file = '~/Desktop/old_file.rb.rb.rb')
    @delete_files << (new_file = './new_file.rb.txt.rb')
    
    system(%! echo "test 12345" > #{old_file}!)
    old_file.file.create_alias(new_file)
    demand_true( File.exists?(new_file.expand_path) )
    
  end
  
  it 'uses expanded paths' do
    @delete_files << (old_file = '~/Desktop/old_file.1.rb.rb.rb')
    @delete_files << (new_file = '~/Desktop/new_file.2.rb.txt.rb'.expand_path)
    
    system(%! echo "test 135" > #{old_file}!)
    old_file.file.create_alias(new_file)
    demand_true( File.exists?(new_file.expand_path) )
  end
  
  it 'raises ArgumentError if new alias is a non-identical file.' do
    @delete_files << (old_file = '~/Desktop/old_file.300.rb.sass')
    @delete_files << (existing_file = '~/Desktop/existing.file.300.rb.sass')
    
    system(%! echo "test 135" > #{old_file}!)
    system(%! echo "test 456" > #{existing_file}!)
    
    e = begin
      old_file.file.create_alias(existing_file)
    rescue ArgumentError=>err
      err
    end

    demand_equal(
      "File already exists: #{existing_file.expand_path.inspect}", 
      e.message
    )
  end
  
  context 'Acessing files and directories with :relative' 

  it 'allows access to sibling files.' do
    file       = __FILE__.file.directory.ruby_files.first
    found_file = __FILE__.file.relative(File.basename(file))

    demand_equal file, found_file 
  end

  it 'allows access to parent directories.' do
    dir       = File.expand_path( File.join(__FILE__.file.directory.path, '../..') )
    found_dir = __FILE__.file.relative('../..')
    
    demand_equal dir, found_dir
  end

  it 'allows access to files in parent directories.' do
    orig_file  = File.expand_path( File.join( __FILE__.file.directory.path, '../../megauni.rb') )
    found_file = __FILE__.file.relative('../../megauni.rb')
    
    demand_equal orig_file, found_file
  end


end

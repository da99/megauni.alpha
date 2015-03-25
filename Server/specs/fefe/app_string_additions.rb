
class App_String_Additions

  include FeFe_Test

  context ':expand_path'

  it 'raises ArgumentError if string is empty' do
    e = begin
      '  '.expand_path
    rescue ArgumentError=>err
      err
    end
    demand_equal( "String can't be empty.", e.message )
  end
  
  it 'expands path of a directory' do
    demand_equal( File.expand_path(File.dirname(__FILE__)), 
                  File.dirname(__FILE__).expand_path )
  end

  it 'expands path of a file' do
    file_name = File.expand_path(__FILE__).sub(File.expand_path('.'), '')
    demand_equal( File.expand_path( file_name ), file_name.expand_path )
  end


  context ':has_extension?' 

  it 'returns true if extension is at the end' do
    demand_true '~/megauni/megauni.rb'.has_extension?('.rb')
  end

  it 'returns false if extension is in the middle' do
    demand_false '/home/yakka/.rb/file.sass'.has_extension?('.rb')
  end

  it "returns true with an extension lacking beginning period" do
    demand_true '/home/yakka/yakka.sass'.has_extension?('sass')
  end

  it "returns true if asked for extension with a symbol" do
    demand_true '/home/yakka/wat.yaml'.has_extension?(:yaml)
  end

  it 'raises ArgumentError if asked with empty string.' do
    e = begin
      'file.rb'.has_extension?('')
    rescue ArgumentError=>err
      err
    end
    demand_equal "String can't be empty.", e.message
  end
  
  it 'raise ArgumentError if original String is empty.' do
    e = begin
      '  '.has_extension?('.rb')
    rescue ArgumentError=>err
      err
    end
    demand_equal "String can't be empty.", e.message
  end
  
  context ':replace_extension' 

  before {
    base_path = '/home/yakka/yakka'
    @file      = base_path + '.sass'
    @new_file  = base_path + '.css'
  }

  it 'returns new String with new extension' do
    demand_equal @new_file, @file.replace_extension('.css')
  end

  it 'returns new String with new extension from Symbol' do
    demand_equal @new_file, @file.replace_extension(:css)
  end

  it 'returns new String with new extension lacking beginning dot.' do
    demand_equal @new_file, @file.replace_extension('css')
  end
  
  it 'raises ArgumentError if new extension is an empty String.' do
    e = begin
      @file.replace_extension '  '
    rescue ArgumentError => err
      err
    end
    demand_equal "String can't be empty.", e.message
  end
  
  it 'raises ArgumentError if orignal string is an empty String.' do
    e = begin
          ' '.replace_extension '.sass'
        rescue ArgumentError => err
          err
        end
    demand_equal "String can't be empty.", e.message
  end

end # ======== App_String_Additions

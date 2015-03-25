
class Angry_Snoopy
  include Demand_Arguments_Dsl

  def initialize 
    on_assertion_exit {
      raise DemandFailed, assertion_exit_msg
    }
  end

  def do_this &blok
    instance_eval( &blok )
  end

end # ======== Angry_Snoopy

class App_Demand_Arguments 

  include FeFe_Test

  before {
    @pony = Angry_Snoopy.new
  }

  it 'reminds hacker to get it done.' do
    e = begin
      @pony.do_this { demand_to_be_done  }
    rescue DemandFailed => err
      err
    end
    demand_regex_match( /Please implement/,
                       e.message )
  end

  context 'Booleans & Equality' # =================================== 

  it 'demands a false' do
    @pony.do_this { demand_false( 1 == 2 ) }
    e = begin
      @pony.do_this { demand_false 1==1 }
    rescue DemandFailed=>err
      err
    end
    demand_regex_match( /This needs to be false/, e.message )
  end

  it 'demands a true' do
    @pony.do_this { demand_true( 3 == 3 ) }
    e = begin
      @pony.do_this { demand_true 3==1 }
    rescue DemandFailed=>err
      err
    end
    demand_regex_match( /This needs to be true/, e.message )
  end
  
  it 'demands equality' do
    @pony.do_this { demand_equal 100, 100.0 }
    e = begin
      @pony.do_this { demand_equal 'string', 'STRING' }
    rescue DemandFailed => err
      err
    end
    demand_regex_match( /These must be equal: #{'string'.inspect}, #{'STRING'.inspect}/, e.message )
  end
  
  context 'Regexp' # =================================== 

  it 'demands a regex' do
    @pony.do_this { demand_regex( /Wat Wat/ ) }
    e = begin
      @pony.do_this { demand_regex :regex }
    rescue DemandFailed=>err
      err
    end
    demand_regex_match( /Regexp is required\: \:regex/, e.message )
  end
  
  it 'demands a String matches against a Regexp' do
    @pony.do_this { demand_regex_match( /YOYO/, 'YOYO' ) }
    e = begin
      @pony.do_this { demand_regex_match( /YOYO/, 'WatWat' ) }
    rescue DemandFailed=>err
      err
    end
    if e.message != "String does not match Regex: /YOYO/, #{'WatWat'.inspect}"  
      raise "Fail"
    end
  end
  
  context 'Strings & Symbols' # =================================== 
  
  it 'demands a string' do
    @pony.do_this { demand_string 'string' }
    e = begin
      @pony.do_this { demand_string :string }
    rescue DemandFailed=>err
      err
    end
    demand_regex_match( /A String is required\: \:string/, e.message )
  end
  
  it 'demands a non-empty string' do
    @pony.do_this { demand_string_not_empty 'string' }
    e = begin
      @pony.do_this { demand_string_not_empty '' }
    rescue DemandFailed=>err
      err
    end
    demand_regex_match( /String must not be empty/, e.message )
  end

  it 'demands a string when it demands a non-empty string' do
    e = begin
      @pony.do_this { demand_string_not_empty :string }
    rescue DemandFailed=>err
      err 
    end
    demand_regex_match( /A String is required\: \:string/, e.message )
  end

  it 'demands a symbol' do
    @pony.do_this { demand_symbol :yo }
    e = begin
      @pony.do_this { demand_symbol 'yo' }
    rescue DemandFailed=>err
      err
    end
    demand_regex_match( /A Symbol is required: #{'yo'.inspect}/, e.message )
  end

  context 'Hashes & Arrays' # =================================== 
  
  it 'demands a hash' do
    @pony.do_this { demand_hash( {:a=>:b} ) }
    e = begin
      @pony.do_this { demand_hash([:a, :b]) }
    rescue DemandFailed=>err
      err
    end
    demand_equal( "A Hash is required\: #{[:a, :b].inspect}", e.message )
  end
  
  it 'demands and allows keys from a hash' do
    @pony.do_this {
      demand_hash({:a=>:b, :c=>:d}) {
        demand :a
        allow :c
      }
    }
    e = begin
      @pony.do_this { 
        demand_hash({:a=>:b, :b=>:c, :c=>:d}) do
          demand :a
          allow :b
        end
      }
    rescue DemandFailed=>err
      err
    end
    demand_equal("Invalid keys: :c", e.message)
  end
  
  it 'demands keys, even if they are missing.' do
    @pony.do_this {
      demand_hash({:a=>:b, :c=>:d}) {
        demand :a, :c
      }
    }
    e = begin
      @pony.do_this { 
        demand_hash({:a=>:b, :b=>:c, :c=>:d}) do
          demand :a, :b, :c, :d
        end
      }
    rescue DemandFailed=>err
      err
    end
    demand_equal("Missing keys: :d", e.message)
  end
  
  it 'demands an Array' do
    @pony.do_this { demand_array [1,2,3] }
    e = begin
      @pony.do_this { demand_array({}) }
    rescue DemandFailed=>err
      err
    end
    demand_equal("An Array is required: #{{}.inspect}", e.message)
  end

  it 'demands a non-empty Array' do
    @pony.do_this { demand_array_not_empty([1,2,3]) }
    e = begin
      @pony.do_this { demand_array_not_empty([]) }
    rescue DemandFailed=>err
      err
    end
    demand_equal( 
        "Array can't be empty: #{[].inspect}",
        e.message 
    )
  end
   
  it 'demands an Array when checking to see if it is not empty' do
    e = begin
      @pony.do_this { demand_array_not_empty({}) }
    rescue DemandFailed=>err
      err
    end
      demand_equal( 
        "An Array is required: #{{}.inspect}",
        e.message 
      )
  end
  
  it 'demands an element is included in the Array.' do
    @pony.do_this { demand_array_includes [1,2,3], 2 }
    e = begin
      @pony.do_this { demand_array_includes [1,2,3], 1000 }
    rescue DemandFailed=>err
      err
    end
      demand_equal( 
        "Missing element in Array: #{1000} --> #{[1,2,3].inspect}",
        e.message
      )
  end
  

  it 'demands an Array when checking to see if elements is in the Array.' do
    e = begin
      @pony.do_this { demand_array_includes({:a=>:b}, :a)}
    rescue DemandFailed=>err
      err
    end
      demand_equal( "An Array is required: #{{:a=>:b}.inspect}", e.message )
  end
  
  
  it 'demands an element is *not* included in the Array.' do
    @pony.do_this { demand_array_not_include [1,2,3], 4 }
    e = begin
      @pony.do_this { demand_array_not_include [1,2,3], 2 }
    rescue DemandFailed=>err
      err
    end
      demand_equal( 
        "Element should not be in Array: #{2} --> #{[1,2,3].inspect}",
        e.message
      )
  end
  

  it 'demands an Array when checking to see if element is *not* in the Array.' do
    e = begin
      @pony.do_this { demand_array_not_include({:a=>:b}, :a)}
    rescue DemandFailed=>err
      err
    end
      demand_equal( "An Array is required: #{{:a=>:b}.inspect}", e.message )
  end
  
  context 'Bindings & Blocks'

  it 'demands a binding' do 
    @pony.do_this { demand_binding binding }
    e = begin
      @pony.do_this { demand_binding :binding }
    rescue DemandFailed => err
      err
    end
      demand_regex_match( /A Binding is required\: \:binding/, e.message)
  end

  it 'demands a block' do
    def @pony.block_demand &blok
      demand_block blok
    end 
    @pony.block_demand { 'yo yo'}
    e = begin
      @pony.block_demand
    rescue DemandFailed=>err
      err
    end
      demand_equal( 
        "A Block is required: #{nil.inspect}",
        e.message
      )
  end

  it 'demands a binding when demanding a block is given' do
    def @pony.block_given_demand &blok
      demand_block_given :binding
    end 
    e = begin
      @pony.block_given_demand { 'yoyo' }
    rescue DemandFailed=>err
      err
    end
      demand_equal(
        "A Binding is required: :binding",
        e.message
      )
  end

  it 'demands a block is given' do
    def @pony.block_given_demand &blok
      demand_block_given binding
    end
    
    @pony.block_given_demand { 'yoyo' }

    e = begin
      @pony.block_given_demand
    rescue DemandFailed=>err
      err
    end
      demand_equal(
        "A Block is required.",
        e.message
      )
  end

  it 'demands a binding when demanding no block is given.' do
    
    def @pony.no_block_given
      demand_no_block_given :b
    end

    e = begin
      @pony.no_block_given
    rescue DemandFailed=>err
      err
    end
      demand_equal(
        "A Binding is required: :b",
        e.message
      )

  end
  
  it 'demands no block is given' do
    def @pony.no_block_given 
      demand_no_block_given binding
    end

    @pony.no_block_given

    e = begin
      @pony.no_block_given { 'yoyo' }
    rescue DemandFailed => err
      err
    end
      demand_equal( 
        "No Block allowed.",
        e.message
      )
  end

  context 'Files & Directories'
  
  it 'demands a directory exists' do
    @pony.do_this { demand_directory_exists '~/' }
    e = begin
      @pony.do_this { demand_directory_exists '~/yakka_yakka' }
    rescue DemandFailed=>err
      err
    end
      demand_equal(
        "An existing directory is required: #{'~/yakka_yakka'.inspect}",
        e.message
      )
  end
  
  it 'demands a file exists' do
    @pony.do_this { demand_file_exists __FILE__ }
    e = begin
      @pony.do_this { demand_file_exists( __FILE__ + 'z' ) }
    rescue DemandFailed=>err
      err
    end
      demand_equal(
        "An existing file is required: #{(__FILE__+'z').inspect}",
        e.message
      )
  end

  it 'demands a specified file matches to the symbolic link' do
    
    home       = '~/'.expand_path
    link_name  = Dir.entries(home).detect { |obj| 
                  File.symlink?(File.join(home,obj)) 
                 }
    link       = File.join(home, link_name)
    file       = File.readlink(link)
    other_file = File.dirname(__FILE__).directory.ruby_files.first

    @pony.do_this {
      demand_sym_link_matches {
        from link
        to file
      }
    }
    
    e = begin
      @pony.do_this {
        demand_sym_link_matches {
          from link
          to other_file
        }
      }
    rescue DemandFailed=>err
      err
    end
      demand_equal(
        "File and symbolic link must match: #{link.inspect}, #{other_file.inspect}",
        e.message
      )
  end



end # ======== App_Demand_Arguments

__END__

  it '' do
    @pony.do_this { demand_ }
    begin
      @pony.do_this {  }
    rescue DemandFailed=>e
      demand_regex_match( //, e.message )
    end
  end
  

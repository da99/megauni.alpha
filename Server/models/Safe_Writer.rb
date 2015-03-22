require 'models/Delegator_Dsl'
require 'modules/Dslicious'
require 'models/Config_Switches'

def String_for_Safe_Writer raw_txt
  txt = raw_txt.dup
  txt.extend String_for_Safe_Writer
  txt
end

module String_for_Safe_Writer
  def folder
    File.basename(File.dirname(self))
  end
  
  def name
    File.basename(self)
  end
end

class Safe_Writer

  extend Delegator_Dsl
  extend Dslicious
  
  ACTIONS = ['read', 'write']
  OBJECTS = ['folder', 'file']
  MATRIX  = permutate(ACTIONS, OBJECTS)
  OPS     = inside_map(MATRIX) { join('_').to_sym }
  
  attr_reader :config, :file
  
  delegate_to 'File',       :expand_path
  delegate_to 'config.ask', :verbose?, :sync_modified_time?
  delegate_to 'config.get', *OPS

  def initialize &configs
    
    @file = Class.new {
      
      attr_accessor :from, :to
      
      def set op, raw_txt
        txt = String_for_Safe_Writer(raw_txt)
        instance_variable_set( "@#{op}".to_sym, txt)
      end
      
    }.new
    
    @config = Config_Switches.new {
      switch :verbose, false
      switch :sync_modified_time, false
      arrays *OPS
    }

    @config.put &configs
    
  end

  def has_from_file?
    !!(file.from)
  end

  def from raw_file
    file.set :from, raw_file
    readable_from_file!
    self
  end

  def write raw_file, raw_content
    
    file.set :to, raw_file
    content = raw_content.to_s

    writable_file!
    puts("Writing: #{file.to}") if verbose?
    
    File.open( file.to, 'w' ) do |io|
      io.write content
    end
    
    if sync_modified_time? && has_from_file?
      touch( file.from, file.to ) 
    end
    
    self
  end
  
  def touch *args
    command = args.map { |str| 
      %~touch "#{str}"~
    }.join( ' && ' )
    
    `#{command}`
  end

  def readable_from_file!
    validate_file! read_file, file.from, :read
  end

  def writable_file!
    validate_file! write_file, file.to, :write
  end

  def validate_file! validators, file, op = "unknown action"
    valid_folder = validate validators, file.folder
    valid_file   = validate validators, file.name
      
    unless valid_folder && valid_file
      raise "Invalid file for #{op}: #{file}" 
    end
  end

  def validate validators, val
    return true if validators.empty?
    
    validators.detect { |dator|
      case dator
      when String
        val == dator
      when Regexp
        val =~ dator
      end
    }
  end

end # === class



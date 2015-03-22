#!/home/da01/Documents/ruby-ee/bin/ruby -w
# -*- ruby -*-

#
#
# Make sure warnings are turned on with "ruby -w".
#
#


$KCODE = 'UTF8'
require 'rubygems'
require 'open3'


%w{
  string_additions
  symbol_additions
  demand_arguments_dsl
  color_puts
}.each { |file|
  require( 'helpers/app/'+file)
}


# ===================================================
# ======== Where the action begins...
# ===================================================

class FeFe_The_French_Maid

  # ======== Constants are in their own module
  # ======== in order to include them in each
  # ======== FeFe class using :include.
  module Prefs
    TASK_DIRECTORY = File.expand_path('~/megauni/helpers/fefe/tasks')
    MY_LIFE        = '~/MyLife'.directory.path
    MY_PREFS       = MY_LIFE.directory.down( 'prefs' )
    PRIMARY_APP    = 'megauni'
    APP_NAME       = File.basename(File.expand_path('.'))
  end

  # ======== When FeFe is given a set of orders, they are 
  # ======== parsed and stored here.
  attr_reader :orders

  class << self
    
    def parse_collection_colon_task str
      lib, raw_task  = str.split(':')[0,2].map(&:strip)
      task           = raw_task.to_sym if raw_task
      lib_class      = collection_name_to_class lib
      return [lib, task, lib_class]
    end

    def collection_name_to_class lib
      
      lib_class_name = lib.split('_').map(&:capitalize).join('_')
      
      begin
        
        Object.const_get(lib_class_name)
        
      rescue NameError
        
        file_name = File.join(Prefs::TASK_DIRECTORY, lib )

        begin
          require file_name
        rescue LoadError
          raise LoadError, "Error for #{lib.inspect}: #{$!.message}"
        end



        Object.const_get(lib_class_name)
        
      end
      
    end
    
  end # ======== class << self

  def parse_order *args
    current_order = nil 
    @orders = {:global => [], :task_order => []}
    current_option = nil
    args.flatten.each { |arg|
      if arg[/.+\:.+/] && !arg[' '] # Avoid strings with ':', like Git commit messages.
        current_order = arg
        @orders[:task_order] << current_order
        @orders[current_order] = {:global=>[]}
      else
        if current_order
          if arg[/^\-/] 
            current_option = arg.sub(/\-+/,'').strip.to_sym
            @orders[current_order][current_option] ||= ''
          else
            if current_option
              @orders[current_order][current_option] += ' ' + arg
              @orders[current_order][current_option] = @orders[current_order][current_option].strip
            else
              raise ArgumentError, "Option has no key: #{arg.inspect} --- all arguments: #{args.inspect}"
            end
          end
        else
          @orders[:global] << arg.sub(/^\-+/, '')
        end
      end
    }
    
    orders
  end

  def run_task_from_argv
    parse_order( *ARGV  )
    if !@orders[:global].empty?
      
      @orders[:global].each { |k|
        case k.upcase
        when 'NO_COLOR_PUTS'
          ENV[k.upcase] = 'true'
        else
          raise ArgumentError, "Unknown global option for FeFe: #{k.inspect}"
        end
      }
    end

    @orders[:task_order].map { |task_name|
      run_task( task_name, @orders[task_name] )
    }
  end

  def run_task lib_and_task, opts_hash = {}

    lib, task, maid_class = self.class.parse_collection_colon_task(lib_and_task)
    maid                  = maid_class.new
    maid.run_task task, opts_hash
  end


end # === FeFe_The_French_Maid =================================




# ===================================================
# ======== This is used in defining
# ======== a new collection.
# ===================================================

module FeFe
  
  include Demand_Arguments_Dsl
  include FeFe_The_French_Maid::Prefs
  include Color_Puts

  def self.included new_class
    new_class.send :extend, Class_Methods
  end

  module Class_Methods

    include Demand_Arguments_Dsl
    include Color_Puts

    def tasks
      @tasks ||= {} 
    end

    def describe name, &blok

      demand_sym name

      i = FeFe_Dsl::Task_Dsl.new( name, &blok ).info

      demand_string i.it
      demand_block  i.steps

      tasks[name] = Struct.new( 
                               :name, :it, :options, :steps
                              ).new( name, i.it, i.options, i.steps)

                              define_method "__fefe_task_#{name.bang_to_bang}__", &tasks[name].steps
    end 

  end # ======== Class_Methods
  
 
  def fefe_run task_name, opts={}
    FeFe_The_French_Maid.new.run_task(task_name, opts)
  end


  def run_task task_name, raw_args 
    
    demand_symbol task_name

    task_info = self.class.tasks[task_name] || self.class.tasks[task_name.bang_to_bang]
    unless task_info
      raise ArgumentError, "Task does not exist: #{task_name.inspect}"
    end
    
    opts = task_info.options
    args = opts.inject([]) { |m,i|
      
      a_name, a_default = i
      
      m <<  ( 
             (raw_args.has_key?(a_name) && raw_args[a_name]) ||
              (opts.index(i) && raw_args[:global][opts.index(i)] ) ||
              a_default
            )
      
      m
    }

    send("__fefe_task_#{task_name.bang_to_bang}__", *args)
  end
  
  def development?
    ENV['RACK_ENV'] == 'development' || !ENV['RACK_ENV']
  end

  def shell_out(*args, &blok)
    stem          = args.shift
    cmd           = stem % ( args.map { |s| s.to_s.inspect } )

    results, errors = Open3.popen3( cmd ) { |stdin3, stdout3, stderr3|
      [ stdout3.readlines, stderr3.readlines ]
    }
    
    if !errors.empty?

      if block_given?
        return blok.call(results, errors)
      end
      
      puts_red '========  Error from shell_out:  =========  '
      errors.join("\n").each { |err|
        puts_red err
      }      
      
      exit(1)
      
    end
    
    results.join(" ")
  end  
  
  def create_directory raw_new_dir
    new_dir = raw_new_dir.expand_path
    return true if new_dir.directory?
    raise ArgumentError, "Non-directory already exists: #{new_dir.inspect}" if new_dir.exists?
    system("mkdir #{new_dir.inspect}")
  end

end # ======== FeFe

module FeFe_Dsl

  class Task_Dsl

    include Demand_Arguments_Dsl
    
    def initialize task_name, &blok
      @task_name = task_name
      instance_eval( &blok )
    end

    def info
      @info ||= Struct.new(:it,:steps, :options).new
    end

    def it text
      demand_string text
      info.it = text
    end

    def steps *opts, &blok
      info.options = opts
      info.steps = blok
    end

  end # === Task_Dsl



end # === FeFe_Dsl


# ===================================================
# ======== FeFe can also be run within 
# ======== other Ruby scripts.
# ===================================================
if $0 == __FILE__ 
  puts
  FeFe_The_French_Maid.new.run_task_from_argv.inspect
  puts
end # ===============================================



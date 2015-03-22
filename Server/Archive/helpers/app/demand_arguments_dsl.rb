
DemandFailed = Class.new(StandardError)

# ===================================================
#                    Main DSL 
# ===================================================

module Demand_Arguments_Dsl

    attr_accessor :assertion_exit_msg, :assertion_call_back

    def on_assertion_exit( &new_proc )
      if !@on_assertion_exit 
        @on_assertion_exit = proc {
          puts assertion_call_back
          raise DemandFailed, assertion_exit_msg
        }
      end
      if block_given?
        @on_assertion_exit = new_proc
      end
      @on_assertion_exit
    end

    def read_around_line raw_file, raw_line, surround = 2

      file         = File.expand_path(raw_file)
      line         = raw_line.to_i
      
      if !File.file?(file)
        return "\e[31mFile not found: #{file}: #{line}\e[0m" 
      end
      
      file         = File.expand_path(raw_file)
      line         = raw_line.to_i

      file_content = File.read(file)
      starting     = line - surround
      ending       = line + surround
      c_line = line - surround
      file_content.split("\n")[starting..ending].map { |l|
        c_line += 1
        if c_line == line 
          "\e[31m#{c_line}: #{l}\e[0m"
        else
          "#{c_line}: #{l}"
        end
      }.join("\n")
    end

    def print_and_exit msg, shift_entries = 2
      msg ||= "Unknown assertion error."
      @using_gems ||= Object.const_defined?(:Gem)
      entries = caller[shift_entries,caller.size].map { |l|
        use_it = if @using_gems
          use_it = !Gem.default_path.detect { |lp|
            l[lp] || l['ruby/site_ruby']
          }
        else
          true
        end
        if use_it
          l.split(':')[0,2]
        else
          nil
        end
      }.compact.uniq
      
      seirtne = entries.reverse
      
      @assertion_exit_msg = msg
      @assertion_call_back ||=''
      
      seirtne.each { |l|
         
        file, line = l

        @assertion_call_back += %~
#{'*' * msg.size}
#{ file }:#{line}
#{'*' * msg.size}
#{read_around_line(file, line)}
#{'*' * msg.size}
~
        
      }

      @assertion_call_back = @assertion_call_back + %~

\e[31m
#{' =' * (msg.size/2)}        
#{msg}
#{' =' * (msg.size/2)}  
\e[0m

      ~
      
      instance_eval( &on_assertion_exit )

    end
    
    def demand_to_be_done
      print_and_exit "Please implement this part of the program.", 1
    end

    
    # ===================================================
    # ======== Equality & Booleans
    # ===================================================
    
    def demand_false bool
      return true if bool == false
      print_and_exit "This needs to be false: #{bool.inspect}"
    end

    def demand_true bool
      return true if bool == true
      print_and_exit "This needs to be true: #{bool.inspect}"
    end

    def demand_equal one, two
      return true if one == two
      print_and_exit("These must be equal: #{one.inspect}, #{two.inspect}")
    end
    
    def demand_not_equal one, two
      return true if one != two
      print_and_exit("These must not be equal: #{one.inspect}, #{two.inspect}")
    end
    
    # ===================================================
    # ======== Regexp
    # ===================================================
    

    def demand_regex re
      return true if re.is_a?(Regexp)
      print_and_exit "Regexp is required: #{re.inspect}"
    end

    def demand_regex_match re, str
      demand_regex re
      demand_string str
      match = str =~ re
      return match if match
      print_and_exit "String does not match Regex: #{re.inspect}, #{str.inspect}"
    end

    
    # ===================================================
    # ======== Strings & Symbols
    # ===================================================
    
    def demand_string s
      if !s.is_a?(String)
        print_and_exit "A String is required: #{s.inspect}"
      end
      s
    end
    
    def demand_string_not_empty raw_s
      demand_string raw_s
      s = raw_s.strip
      return s unless s.empty?
      print_and_exit "String must not be empty."
    end
    
    def demand_symbol sym
      return sym if sym.is_a?(Symbol)
      print_and_exit "A Symbol is required: #{sym.inspect}"
    end
    alias_method :demand_sym, :demand_symbol

    
    # ===================================================
    # ======== Hashes & Arrays
    # ===================================================
    
      
    def demand_hash arg, &blok
      if !arg.is_a?(Hash)
        print_and_exit( "A Hash is required: #{arg.inspect}" )
      end
      
      if block_given?
        h_v = Dsl_For_Demand_Hash.new
        h_v.instance_eval( &blok )
        invalid = (arg.keys - h_v.keys).map(&:inspect)
        missing = (h_v.demand - arg.keys).map(&:inspect)
        if !invalid.empty?
          print_and_exit "Invalid keys: #{invalid.join(', ')}"
        end
        if !missing.empty?
          print_and_exit "Missing keys: #{missing.join(', ')}"
        end
      end
      arg
    end

    def demand_array arr
      return true if arr.is_a?(Array)
      print_and_exit "An Array is required: #{arr.inspect}"
    end
    
    def demand_array_not_empty arr
      demand_array arr
      return true if !arr.empty?
      print_and_exit "Array can't be empty: #{arr.inspect}"
    end

    def demand_array_includes arr, ele
      demand_array arr
      return true if arr.include?(ele)

      print_and_exit "Missing element in Array: #{ele.inspect} --> #{arr.inspect}"
    end
    
    def demand_array_not_include arr, ele
      demand_array arr
      return true if !arr.include?(ele)

      print_and_exit "Element should not be in Array: #{ele.inspect} --> #{arr.inspect}"
    end
    
    # ===================================================
    # ======== Blocks
    # ===================================================

    def demand_binding b
      if !b.is_a?(Binding)
        print_and_exit "A Binding is required: #{b.inspect}"
      end
      b
    end    
    
    def demand_block blok
      return blok if blok.is_a? Proc
      print_and_exit "A Block is required: #{blok.inspect}"
    end

    def demand_block_given b
      demand_binding b
      return true if eval("block_given?", b)
      print_and_exit "A Block is required."
    end

    def demand_no_block_given b
      demand_binding b
      blok_given = eval("block_given?", b)
      return true unless blok_given
      print_and_exit "No Block allowed."
    end
    
    # ===================================================
    # ======== Files & Directories
    # ===================================================
    
    def demand_directory_exists raw_arg
      dir = File.expand_path(raw_arg)
      return dir if File.directory?(dir)
      print_and_exit "An existing directory is required: #{raw_arg.inspect}"
    end

    def demand_file_exists raw_file
      file = File.expand_path(raw_file)
      return file if File.file?(file)
      print_and_exit "An existing file is required: #{raw_file.inspect}"
    end

    def demand_exists_on_filesystem raw_path
      obj = File.expand_path(raw_path)
      return obj if File.exists?(obj)
      print_and_exit "A valid file or directory is required: #{raw_path.inspect}"
    end

    def demand_not_exists_on_filesystem raw_path
      obj = File.expand_path(raw_path)
      return obj if !File.exists?(obj)
      print_and_exit "File or directory must not exist: #{raw_path.inspect}"
    end

    def demand_sym_link_matches &blok
      demand_block blok
      dsl =  Dsl_For_Demand_Sym_Link_Matches.new(&blok)
      if !File.identical?(dsl.to, dsl.from)
        print_and_exit("File and symbolic link must match: #{dsl.from.inspect}, #{dsl.to.inspect}")
      end
    end

end # === Demand_Arguments_Dsl


# ===================================================
#              DSL Implementations
# ===================================================


class Dsl_For_Demand_Sym_Link_Matches

  def initialize &blok
    instance_eval( &blok )
  end

  def from *old_file
    return @from if old_file.empty?
    @from = File.join(*old_file).file_system_name 
  end

  def to *new_file
    return @to if new_file.empty?
    @to = File.join(*new_file).file_system_name
  end

end


class Dsl_For_Demand_Hash
    def keys
      [demand, allow].flatten
    end
    def demand *args
      @demand ||= []
      @demand = (@demand + args).flatten
      @demand
    end 
    def allow *args
      @allow ||= []
      @allow = (@allow + args).flatten
      @allow
    end 
end # === Dsl_For_Demand_Hash


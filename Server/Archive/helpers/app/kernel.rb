

module Kernel

   private # =========================================

   def __previous_method_name__
     caller[1] =~ /`([^']*)'/ && $1.to_sym
   end

   def __method_name__
     caller[0] =~ /`([^']*)'/ && $1.to_sym
   end

   def __previous_line__
    caller[1].sub(file.dirname(file.expand_path('.')), '')
   end
   
   def require_hash_keys h, *k_arr
    valid   = k_arr.flatten
    invalid = h.keys - valid
    if !invalid.empty?
      raise ArgumentError, "Invalid keys in #{__previous_method_name__}: #{invalid.inspect}"
    end

    true
   end

   def at_least_something?( unknown )
   
    return false if !unknown
   
    if unknown.respond_to?(:strip)
      stripped = unknown.strip
      return stripped if !stripped.empty?
    elsif unknown.is_a?(numeric)
      return unknown if unknown > 0 
    else
      unknown
    end
    
    false
   end

   def assert_size obj, raw_target_size
     meth =  obj.respond_to?(:jsize) ? :jsize : :size 
     size = obj.send(meth)
     target = Integer(raw_target_size)
     if not (size === target)
       raise ArgumentError, "Object is wrong #{meth}: #{obj.inspect}, SIZE: #{size}"
     end
     size
   end

   def assert_not_empty obj
     empty, val = case obj
             when nil
               [false, nil]
             when String
               str = obj.strip
               [str.empty?, str]
             else
               if obj.respond_to?(:empty)
                 [obj.empty?, obj]
               else 
                 raise ArgumentError, "Can't check for emptiness: #{obj.inspect}"
               end
             end
     if empty
       raise ArgumentError, "Object must not be empty: #{obj.inspect}"
     end

     val

   end

   def assert_match regexp, str
     if not str.is_a?(String)
       raise ArgumentError, "#{str} must be a String."
     end
     match = (regexp =~ str)
     if not match
       raise ArgumentError, "Invalid characters: #{str.inspect}"
     end
     match
   end

   def assert_dir_exists str
     exists = File.directory?(str)
     if not exists
       raise ArgumentError, "Directory does not exist: #{str.inspect}"
     end
     File.expand_path(str)
   end

   def assert_valid_keys hash, valid_keys
     invalid = hash.keys - valid_keys
     return true if invalid.empty?
     raise ArgumentError, "Invalid keys: #{invalid.map(&:inspect).join(', ')}"
   end

   def assert_included arr, val
     return true if arr.include?(val)
     raise ArgumentError, "Invalid value: #{val.inspect}. Allowed Values: #{arr.map(&:inspect).join(', ')}"
   end

end

# class Object
# 
#   private
#   def use_method_once
#     meth = __previous_method_name__ 
#     @methods_only_once ||= []
#     raise "#{meth} can only be used once." if @methods_only_once.include?(meth)
#     @methods_only_once << meth
#   end
# 
# end


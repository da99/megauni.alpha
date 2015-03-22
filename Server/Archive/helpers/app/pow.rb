
require 'pow'

if !Pow('~').is_a?(Pow::Directory)
  module Pow

    class Base
      def self.open(*paths, &block) #:nodoc:
        paths.collect! {|path| path.to_s}
        
        raw_path = ::File.join(paths)
        expanded_path = ::File.expand_path(raw_path)
        klass = nil
        
        path = [raw_path, expanded_path].detect { |loc|
            klass = if ::File.directory?(loc)
              Directory
            elsif ::File.file?(loc)
              File
            end
        } 
        
        path ||= raw_path
        klass ||= self
    
        klass.new(path, &block)
      
      end
    end
  end

  def Pow!(*args, &block)
    file_path = ::File.dirname caller[0].split(':in ').first
    Pow(file_path, *args, &block)
  end
end # == if


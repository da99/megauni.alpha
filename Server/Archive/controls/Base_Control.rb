require 'views/Base_View'
require 'models/Hash_Sym_Or_Str_Keys'

module Base_Control
  
  REG_MAPS = {
    ':year'    => "[0-9]{2,4}",
    ':month'   => "[0-9]{1,2}",
    ':filename' => '[a-zA-Z0-9\_\-\.]{1,}',
    ':club_filename' => '[a-zA-Z0-9\_\-\.]{1,}',
    ':label' => '[a-zA-Z0-9\_\-\.]{1,}',
    ':id'  => '[a-zA-Z0-9]{1,}',
    ':_id' => '[a-zA-Z0-9]{5,}',
    ':cgi_escape' => '[a-zA-Z0-9\%\.\_\-\=\+\&\!]{1,}'
  }

  KEY_REG = %r!#{REG_MAPS.keys.join('|')}!
    

  # ======== Class Methods  ======== 
  class << self
    def included klass
      klass.extend Class_Methods
    end
  end # === class << self

  module Class_Methods
    
    def top_slash
      @path = '/'
    end
    
    def current_path
      @path
    end
    
    def path sub_path
      @path = sub_path
    end
    
    def allow level
      @security_level = Member.const_get(level)
    end
    
    def security_level
      @security_level 
    end
        
    def compile_route raw_unknown
      is_file = raw_unknown['.']
      unknown = if is_file
                  File.join(current_path, raw_unknown)
                else
                  File.join(current_path, raw_unknown, '/')
                end
                  
      return unknown unless unknown[KEY_REG]

      keys = []
      final_path = begin
                     unknown.split('/').map { |sub|
                       target = ( REG_MAPS[sub] && "(#{REG_MAPS[sub]})" )
                       if target
                         keys << sub.sub(':', '')
                       end
                       target || sub
                     }.join('/')
                   end

      pattern = %r!\A#{final_path}/\Z!
      eval %~
        def pattern.keys
          #{keys.inspect}
        end
      ~
      pattern
    end

    def redirect path = nil, &blok
      Uni_App::Redirector.new(self, path, &blok)
    end

    def method_missing name, *args, &blok
      return super unless [:get, :post, :put, :delete].include?(name)
      
      raise(
        ArgumentError, 
        "Arguments must contain at least: " + 
        "1 path, 1 security level: #{args.inspect}"
      ) if args.size < 2

      sub_path = args.shift
      level    = Member.const_get( args.shift )
      raise ArgumentError, "Unknown arguments: #{args.inspect}" unless args.empty?
      controller = self

      action_name = case sub_path
                    when Symbol
                      action_name = sub_path
                      sub_path = "/#{action_name}"
                      action_name
                    else
                      nil
                    end
      
      the_base_path = current_path      
      final_path = compile_route(sub_path)

      if Uni_App.development?
        puts "CREATING: #{name} #{final_path}"
      end

      Uni_App.send(name, final_path ) do
        base_path the_base_path
        control controller
        if action_name
          action action_name
        end
        min_security_level level
        
        if Uni_App.development?
          puts "PATH: #{request.path_info} CONTROL: #{control} ACTION: #{action_name}"
        end
      
        instance_eval( &blok )
      end

      allow :NO_ACCESS
    end

    # def get sub_path, &blok
    #   controller = self
    #   Uni_App.get File.join(current_path, sub_path, '/') do
    #     control controller.to_s
    #     instance_eval &blok
    #   end
    # end
    
  end # === module Class_Methods

  
  # ======== INSTANCE stuff ======== 
  
end # === Base_Control




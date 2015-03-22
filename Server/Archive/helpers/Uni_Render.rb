require 'templates/html/Template_Context'
require 'templates/html'
require 'templates/xml'

module Sinatra
  
  module Uni_Render

    def render type, txt
      header(:accept_charset, 'utf-8') unless header?(:accept_charset)
      no_cache unless header?(:cache_control)
      content_type type
      txt
    end

    def template alt_file_name = nil
      case alt_file_name
      when :html, :xml, :text
        ext       = alt_file_name
        file_name = "#{control}_#{action}"
      else
        parts     = alt_file_name.split('.')
        ext       = parts.pop.to_sym
        file_name = parts.join('.')
      end
      
      # Process the template.
      template_content = compile(ext, file_name)

      # Set the appropriate headers.
      render ext, template_content
    end # === def template

    def compile raw_ext, file_name
      ext = raw_ext.to_sym
      
      # Get contexts.
      require "views/#{file_name}.rb"
      view_class                       = Object.const_get(file_name)
      view_class.raise_on_context_miss = true
      view_ctx                         = view_class.new(self)
      ctx                              = Mustache::Context.new(view_ctx)
      converter                        = Object.const_get( :"Ruby_To_#{ext.to_s.capitalize}" )
      compile_args                     = case ext
                                         when :html
                                           [ view_ctx.viewer_level, file_name ]
                                         else
                                           [ file_name ]
                                         end
      compiled_file_path               = converter.path( ext, *compile_args )
      # Use newly created contexts to compile templates.
      template_content = unless Uni_App.development? 
                           File.read( compiled_file_path )
                         else
                           puts("Compiling templated instead of using cached Mustache...")
                           require "templates/#{ext}/Compiler"
                           converter.compile( *compile_args )
                         end

      # Eval the compiled mustache code.
      eval(template_content, nil, compiled_file_path, 1)
    end

  end # === module Uni_Render

  helpers Uni_Render
  
end # === module Sinatra




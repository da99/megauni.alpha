
require 'templates/css'
require 'templates/css/Compiler'

class Render_Css

  def initialize new_app
    @app = new_app
    @langs = eval(File.read(File.expand_path("./helpers/langs_hash.rb"))).keys
    @css_regexp = %r!/stylesheets/(#{@langs.join('|')})/([a-zA-Z0-9\_]+)\.css!
  end


  def call new_env
    
    if not (new_env['PATH_INFO'] =~ @css_regexp)
      return( @app.call(new_env) ) 
    end

    lang, file_name = $1, $2
    sass_file_name  = file_name.sub('.css', '') + '.sass'
    css_content     = Ruby_To_Css.compile("templates/#{lang}/css/#{sass_file_name}")
    [200, {'Content-Type' => 'text/css'}, css_content ]
    
  end

end # === Render_Css


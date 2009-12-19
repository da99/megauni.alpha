
require 'sass'
require 'compass'
require 'ninesixty'


get( "/skins/:skin/css/:file.css" ) do |raw_skin, raw_file|

    response['Content-Type'] = 'text/css'
    
    skin_name = ( raw_skin =~ /([a-zA-Z0-9\_\-]{2,})/ && $1)
    file      = ( raw_file =~ /([a-zA-Z0-9\_\-]{2,})/ && $1 )
    
    sass_dir      = File.join( options.views, 'sass' )
    sass_template = File.join( sass_dir , file + '.sass')

    raise( "CSS file not found: #{request.path_info}" ) if !File.file?(sass_template)
        
    ::Sass::Engine.new( 
        File.read(sass_template), 
        :load_paths=> [ sass_dir ] + Compass.sass_engine_options[:load_paths] 
    ).render 
   
end # === get



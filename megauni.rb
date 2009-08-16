$KCODE = 'UTF8'

# ===============================================
# Important Gems
# ===============================================

require 'rubygems'
require 'sinatra'
require 'pow'
require 'sequel' 
require 'sequel/extensions/inflector'

def require_these( dir );
    Pow( dir.strip ).grep(/\.rb$/).each { |f| require f.to_s.sub(/.\rb$/, '') }
end

module Kernel
    private
       def __previous_method_name__
         caller[1] =~ /`([^']*)'/ && $1.to_sym
       end
       
       def __previous_line__
        caller[1].sub(File.dirname(File.expand_path('.')), '')
       end
       
       def at_least_something?( unknown )
       
        return false if !unknown
       
        if unknown.respond_to?(:strip)
          stripped = unknown.strip
          return stripped if !stripped.empty?
        elsif unknown.is_a?(Numeric)
          return unknown if unknown > 0 
        else
          unknown
        end
        
        false
       end
end


# ===============================================
# Configurations
# ===============================================
use Rack::Session::Pool

set :site_title     , 'Mega Uni'
set :site_tag_line  , 'The website that predicts the future.'
set :site_keywords  , 'predict, predictions, future'
set :site_domain    , 'megaUni.com'
set :site_url       , Proc.new { "http://www.#{options.site_domain}/" }
set :site_support_email , Proc.new { "helpme@#{options.site_domain}" }
set :cache_the_templates, Proc.new { !development? }

configure :development do
  `reset` 
  require Pow('helpers/css')
end

configure do

  # Special sanitization library for both Models and Sinatra Helpers.
  require Pow!( 'helpers/wash' )

  # === Include models.
  require Pow!('helpers/model_init')
  

end # === configure 



# ===============================================
# Filters
# ===============================================
before {
    
    require_ssl! if request.cookies["logged_in"] || request.post?
    
    # Chop off trailing slash and use a  permanent redirect.
    if request.get? && 
        request.path_info != '/' &&
          request.path_info[ request.path_info.size - 1 , 1] == '/'
      # new_path = request.path_info
      # new_path += "?#{request.query_string}"if !request.query_string.empty?
      redirect( request.url.sub('/?', '/').sub(/\/$/, '' ) , 301 )  
    end 
               
    # url must not be blank. Sometimes I get error reports where the  URL is blank.
    # I have no idea how that is even possible, so I put this:
    if options.test? && request.env['REQUEST_URI'].to_s.strip.length.zero?
      raise( ArgumentError, "POSSIBLE SECURITY ISSUES: URL is blank." ) 
    end
    
} # === before  


# ===============================================
# Helpers
# ===============================================
require_these 'helpers/sinatra'



# ===============================================
# Require the actions.
# ===============================================
require_these 'actions'


get( '/' ) {
  describe :main, :show
  render_mab
}

get '/salud' do
  describe :main, :salud
  render_mab :layout=>nil
end


get( '/reset' ) {
    TemplateCache.reset
    CSSCache.reset
    redirect( env['HTTP_REFERER'] || '/' )
}

get('/timer/') {
  redirect( '/timer' , 301 )
}

get('/timer') {
  Pow("public/eggs/index.html").read
}

get('/eggs?/?') {
  describe :egg, :show
  render_mab
}



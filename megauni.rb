
require 'roda'
require 'www_app'


module Megauni

  module Rack_Helpers

    def use *args, &blok
      Megauni::Rack_App.send :use, *args, &blok
    end # === def use

  end # === module Server

  class Rack_App < Roda

    plugin :default_headers,
      'Content-Type'=>'text/html',
      'Content-Security-Policy'=>"default-src 'self'",
      'Strict-Transport-Security'=>'max-age=16070400;',
      'X-Frame-Options'=>'deny',
      'X-Content-Type-Options'=>'nosniff',
      'X-XSS-Protection'=>'1; mode=block'

    # 404 errors ===================
    route { |r|
      r.on true do
        response.status = 404
        response.headers["Content-Type"] = 'text/html'
        response.body ::Megauni::FILE_404
      end # on get
    }
  end # === class Rack_App


end # === Megauni

extend Megauni::Rack_Helpers
use Rack::CommonLogger

require 'da99_rack_protect'
use Da99_Rack_Protect do |da99|
  if ENV['IS_DEV']
    da99.config(:host, :localhost)
  else
    da99.config(:host, 'megauni.com')
  end
end

# 500 errors ===================
# We place this at the top level
# to catch any server app errors
# (aka 500).
require "./Server/Megauni/Error_500"
use(Megauni::Error_500)

[
  'Timer_Public_Files',
  'My_Egg_Timer_Redirect',
  'Surfer_Hearts_Archive',
  'Mu_Archive_Redirect',
  'Mu_Archive'
].each { |name|

 require "./Server/Archive/#{name}"
 use Object.const_get(name)

}

if ENV['IS_DEV']
  require "./Server/Archive/Public_Files"
  use Public_Files, [ 'Public', Surfer_Hearts_Archive::Dir ]
end

require './Server/Root/MUE'
require './Server/Root/root'
require './Server/Root/home' if ENV['IS_DEV']
require './Server/Root/@screen_name'
require './Server/Root/post'

Megauni::Rack_App.freeze





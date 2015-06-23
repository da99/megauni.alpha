
require 'cuba'
require 'roda'
require 'www_app'

FILE_403   = File.read("Public/403.html")
FILE_404   = File.read("Public/404.html")
FILE_500   = File.read("Public/500.html")


module Megauni

  class << self
  end # === class << self

  module Rack_Helpers

    def use app, *args, &blok
      Cuba.use(app, *args, &blok)
    end # === def use

  end # === module Server
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
use(
  Class.new {
    def initialize app
      @app = app
    end

    def call env
      dup._call env
    end

    def _call env
      @app.call env
    rescue Object => ex
      if ENV['IS_DEV']
        puts ex.message
        ex.backtrace.each { |b| puts(b.strip) unless b['ruby/gems'] }
      end
      [500, {'Content-Type'=>'text/html'}, [FILE_500]]
    end
  } # === Class.new
) # === use

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

Cuba.define do

  # 404 errors ===================
  on default do
    res.status = 404
    res.headers["Content-Type"] = 'text/html'
    res.write FILE_404
  end # on get

end # === Cuba.define









require 'cuba'
require 'rack/robustness'

FILE_403   = File.read("Public/403.html")
FILE_404   = File.read("Public/404.html")
FILE_500   = File.read("Public/500.html")
FILE_INDEX = File.read('Public/index.html')

# 500 errors ===================
Cuba.use Rack::Robustness do |g|
  g.status       500
  g.content_type 'text/plain'
  g.body         FILE_500
end

require 'da99_rack_protect'
Cuba.use Da99_Rack_Protect do |da99|
  if ENV['IS_DEV']
    da99.config(:host, :localhost) 
  else
    da99.config(:host, 'megauni.com') 
  end
end


%w{
  Timer_Public_Files
  My_Egg_Timer_Redirect
  Surfer_Hearts_Archive
  Mu_Archive_Redirect
  Mu_Archive
  Public_Files
}.each { |name|

 require "./middleware/#{name}"

 case name
 when 'Public_Files'
   Cuba.use Public_Files, [ 'Public', Surfer_Hearts_Archive::Dir ]
 else
   Cuba.use Object.const_get(name)
 end

}

def use app
  Cuba.use(Class.new {
    const_set :APP, app

    def initialize app
      @app = app
    end

    def call env
      status, headers, body = (result = self::class::APP.call env)

      is_empty = status == 404 && (!body || body.empty?)
      if is_empty
        @app.call env
      else
        result
      end
    end
  })
end # def use

use(Cuba.new {
  on get, root do
    res.write FILE_INDEX
  end
})

if ENV['IS_DEV']
  use(Cuba.new {
    on 'raise-error-for-test' do
      something
    end
  })
end

Cuba.define do

  # 404 errors ===================
  on default do
    res.status = 404
    res.write FILE_404
  end # on get

end # === Cuba.define








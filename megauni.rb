
require 'cuba'
require 'rack/robustness'

file_403   = File.read("Public/403.html")
file_404   = File.read("Public/404.html")
file_500   = File.read("Public/500.html")
file_index = File.read('Public/index.html')

# 500 errors ===================
Cuba.use Rack::Robustness do |g|
  g.status       500
  g.content_type 'text/plain'
  g.body         file_500
end

require 'da99_rack_middleware'
Cuba.use Da99_Rack_Middleware

# 404 errors ===================
Cuba.use(Class.new {
  def initialize app
    @app = app
  end

  def call env
    result = @app.call env
    status, headers, body = result
    return result unless status == 404 && body.empty?

    body = file_404
    headers['Content-Length'] = body.length.to_s
    [status, headers, body]
  end
})


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

Cuba.define do

  on get do

    on root do
      res.write file_index
    end

    if ENV['IS_DEV']
      on 'raise-error-for-test' do
        something
      end
    end

  end # on get

end # === Cuba.define



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

# 404 errors ===================
Cuba.use(Class.new {
  def initialize app
    @app = app
  end

  def call env
    result = @app.call env
    status, headers, body = result

    if status == 404 && body.empty?
      headers['Content-Length'] = FILE_404.length.to_s
      headers['Content-Type'] = 'text/html; charset=utf-8'
      [status, headers, [FILE_404]]
    else
      return result
    end
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
      res.write FILE_INDEX
    end

    if ENV['IS_DEV']
      on 'raise-error-for-test' do
        something
      end
    end

  end # on get

end # === Cuba.define


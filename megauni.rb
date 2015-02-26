
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

    name = begin
                  case
                  when root
                    'index'
                  else
                    env['PATH_INFO'].gsub('/'.freeze, '~')
                  end
                end
    ext = env['HTTP_ACCEPT'].split('/').last
    ext = 'unknown' unless ext[/\A[a-z0-9\_\-]+\Z/]
    public_file_name = "Public/#{name}.html"
    file_name        = "Server/actions/#{name}.#{ext}.rb"
    meth_name        = "#{name}_#{ext}".downcase.gsub(/[^_a-z0-9]+/, '__').to_sym

    not_found = false
    if !respond_to?(meth_name)
      case
      when File.exists?(public_file_name)
        eval %~
          def #{meth_name}
            @#{meth_name} ||= File.read(#{public_file_name.inspect})
          end
        ~
      when File.exists?(file_name)
        eval %~
          def #{meth_name}
            #{File.read(file_name)}
          end
        ~, nil, file_name, 3
      else
        not_found = true
      end
    end

    unless not_found
      res.write send(meth_name)
    end

  end # on get

end # === Cuba.define


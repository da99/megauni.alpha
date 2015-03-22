class Redirect_Mobile

  def initialize the_app
    @app = the_app
    @salud_urls = %w{
      /saludm
      /saludm 
      /saludmobi
      /saludiphone
      /saludpda
    }
    @url = /\/(m|mobi|mobile|iphone|pda)\/\z/ 
  end

  def call env
    do_salud    = @salud_urls.detect { |url| env['PATH_INFO'].index(url) === 0 }
    do_redirect = env['PATH_INFO'].index( @url )
    do_stop_mobile = env['PATH_INFO'] == '/stop_mobile_version/'
    if not (do_redirect || do_salud || do_stop_mobile)
      return(@app.call(env))
    end

    response = Rack::Response.new

    if do_redirect || do_salud
      response.set_cookie("use_mobile_version", {
        :value   => 'yes',
        :path    => '/',
        :expires => (Time.now + (60 * 60 * 24 * 365 * 10)),
      }) 
    end
    
    if do_salud
      response.redirect '/salud/m/', 303
    elsif do_redirect
      response.redirect env['PATH_INFO'].sub( @url, '/' ), 303
    else
      response.set_cookie('use_mobile_version', :value=>'no', :expires => (Time.now + (60 * 60 * 24 * 365 * 10)) )
      response.redirect '/', 303
    end
    
    response.finish
  end

end # === Redirect_Mobile

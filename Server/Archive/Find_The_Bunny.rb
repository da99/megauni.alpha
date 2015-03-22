require './models/Mu_Router'

class Find_The_Bunny

  VALID_HTTP_VERBS = %w{ HEAD GET POST PUT DELETE }

  URL_REGEX = Hash[
    :id       => '[a-zA-Z\-\d]+',
    :filename => '[a-zA-Z0-9\-\_\+]+',
    :cgi_escaped => '[^/]{1,90}',
    :digits   => '[0-9]+',
    :old_topics => "#{Old_Topics.join('|')}"
  ]

  private # ==================================================
  def redirect new_url
    response = Rack::Response.new
    response.redirect( new_url, 301 ) # permanent
    response.finish
  end

  public # ==================================================
  def initialize new_app
    @app = new_app
  end

  def call new_env
    new_env['the.app.meta'] ||= {}
    results = Mu_Router.detect(new_env)
    return(@app.call(new_env)) if results

    if new_env['redirect_to']
      return redirect(new_env['redirect_to'])
    end

    raise Uni_App::HTTP_404, "Not found: #{new_env['REQUEST_METHOD']} #{new_env['PATH_INFO']}"
  end



end # === Find_The_Bunny

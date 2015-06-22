require 'mustache'


def Mu_Archive_Read path_info, vals = Hash[]
  content = File.read( Mu_Archive path_info )
  Mustache.raise_on_context_miss = true
  Mustache.render( content, vals )
end

class Mu_Archive

  Perma = 301
  Public_Dir = 'Public/archive'

  def initialize new_app
    @app = new_app
  end

  def call new_env
    path_info = new_env['PATH_INFO']
    orig = @app.call(new_env)

    return orig unless orig.first.to_s == "404"

    f = archive_path(path_info)
    return orig unless f

    r = Rack::Response.new
    r.headers['Content-Type'] = 'text/html'
    r.body = [ File.read(f) ]
    r.finish
  end

  def archive_path path_info
    [
      File.join(Public_Dir, path_info),
      File.join(Public_Dir, path_info) + '.html',
      File.join(Public_Dir, path_info, "/index.html")
    ].detect { |f| File.file? f }
  end # === def Mu_Archive

end # === class







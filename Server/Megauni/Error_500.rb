
module Megauni

  FILE_403 = File.read("Public/403.html")
  FILE_404 = File.read("Public/404.html")
  FILE_500 = File.read("Public/500.html")

  class Error_500

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
      [500, {'Content-Type'=>'text/html'}, [::Megauni::FILE_500]]
    end

  end # === class Error_500

end # === module

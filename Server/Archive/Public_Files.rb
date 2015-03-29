
require "./Server/Archive/Mu_Archive"
require "./Server/Archive/Surfer_Hearts_Archive"

#
# Serve assets: .js, .css, etc.
#
class Public_Files

    EXTS = %w{
      .css
      .swf
      .html
      .mp3
      .wav
      .js
      .gif
      .jpg
      .png
      .ico
      .otf
      /robots.txt
    }

    def initialize(app, folders=[])
      @app = app
      @raw_folders = folders
    end

    def call(e)
      orig = @app.call(e)
      return orig unless orig.first == 404

      path    = e["PATH_INFO"]
      allowed = EXTS.detect { |f| EXTS.include?(File.extname(path)) || EXTS.include?(path) }

      return orig if !allowed

      resp = get_file_response(e)
      return resp if resp

      orig
    end

    def get_file_response e
      folders = @raw_folders.map { |f| Rack::File.new(f) }
      file    = e['PATH_INFO']
      files   = [file, File.join(file, 'index.html') ]
      resp    = nil

      files.detect { |f|
        folders.detect { |folder|
          r = folder.call(e)
          resp = r unless r.first == 404
          resp
        }

        resp
      }

      resp
    end

end # ===

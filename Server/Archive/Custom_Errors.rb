
class Custom_Errors

  def initialize the_app, general_err = RuntimeError
    @app = the_app
    @e_klass = general_err
  end

  def call e
    orig = @app.call e

    case orig.first
    when 401, 100..399
      orig
    else
      keys = %w{
        rack.request.query_hash
        rack.request.query_string
        rack.url_scheme
        HTTP_REFERER
        HTTP_USER_AGENT
        HTTP_HOST
        HTTP_ACCEPT
        HTTP_ACCEPT_LANGUAGE
        PATH_INFO
        QUERY_STRING
        REMOTE_ADDR
        REQUEST_METHOD
        REQUEST_PATH
        REQUEST_URI
        SCRIPT_NAME
        SERVER_NAME
        SERVER_PROTOCOL
      }

      excp = if e['sinatra.error']
               e['sinatra.error']
             else
               temp = @e_klass.new("#{orig.first} #{e['REQUEST_URI']}")
               temp.set_backtrace caller
               temp
             end

      aux  = begin
               e.inject(Hash[]) do |m, (k,v)|
                 m[k.to_s] = case v
                             when String, Integer
                               v
                             else
                               v.inspect
                             end
                 m
               end
             end


      if excp.is_a?(Sinatra::NotFound)
        aux[:message] = "#{orig.first} #{aux['REQUEST_URI']}"
      end

      Dex.insert excp, aux

      status  = orig.first
      headers = orig[1]
      body    = get_body(orig.first) || orig.last
      headers.delete 'Content-Length'

      [status, headers, body]
    end

  end # === def call e

  def get_body num
    file = "public/#{num}.html"
    return nil unless File.exists?(file)
    [ File.read(file) ]
  end

end # === class Custom_Errors

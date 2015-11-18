    # plugin :default_headers,
      # 'Content-Type'=>'text/html',
      # 'Content-Security-Policy'=>"default-src 'self'",
      # 'Strict-Transport-Security'=>'max-age=16070400;',
      # 'X-Frame-Options'=>'deny',
      # 'X-Content-Type-Options'=>'nosniff',
      # 'X-XSS-Protection'=>'1; mode=block'
# use Da99_Rack_Protect do |da99|
  # ENV['IS_DEV'] ?
    # da99.config(:host, :localhost) :
    # da99.config(:host, 'megauni.com')

# var koa_csrf         = require('koa-csrf');
# var csrf_routes = require('./Server/Session/csrf_routes');

  # 403: fs.readFileSync('../megauni.html/Public/403.html').toString(),
  # 404: fs.readFileSync('../megauni.html/Public/404.html').toString(),
  # 500: fs.readFileSync('../megauni.html/Public/500.html').toString(),
# var error_pages = {
  # any: `
# <html>
  # <head>
    # <title>Error</title>
  # </head>
  # <body>
    # Unknown Error.  Try again later.
  # </body>
# </html>`.trim()
# };
# app.use(KOA_GENERIC_SESSION({
  # store: new KOA_PG_SESSION(process.env.DATABASE_URL),
  # cookie: {
    # httpOnly: true,
    # path: "/",
    # secureProxy: !process.env.IS_DEV,
    # maxage: null
  # }
# }));
# app.use(koa_bodyparser({jsonLimit: '250kb'}));
# # app.keys = [
  # process.env.SESSION_SECRET,
  # process.env.SESSION_SECRET + Math.random().toString()
# ];
# // === Set security before routes:
# app.use(helmet());
# app.use(helmet.csp({
  # 'default-src': ["'self'"]
# }));
# if (!process.env.IS_DEV) {
  # app.use(helmet.hsts(31536000, true, true));
# }
# // === Setup error handling:
# // === Send a generic message to client in case 'err.message'
# //     contains sensitive data.
# app.use(koa_errorhandler({
  # debug: !process.env.IS_DEV,
  # html : function () {
    # this.body = error_pages[this.status] || error_pages.any;
  # },
  # json : function () {
    # this.body = JSON.stringify({error: {tags: ['server', this.status], msg: "Unknown error."}});
  # },
  # text : function () {
    # this.body = 'Unknown error.';
  # }
# }));


defmodule Megauni.Router do

  @static Path.expand("../megauni.html/Public")

  use Plug.Builder

  if Megauni.dev? do
    use Plug.Debugger
    plug Log.Debug
    plug Megauni.Router.Static, at: "/", from: @static
  end

  plug Megauni.Router.API
  plug Megauni.Router.Browser

  plug Megauni.Router.Not_Found, html: "#{@static}/404.html"

  # === Helpers/Miscell.: ==========================================

  def static_path do
    @static
  end

  def fulfilled? conn do
    Map.get(conn, :state) == :sent || !is_nil(Map.get conn, :status)
  end

  def no_404? conn do
    Map.get(conn, :status) != Plug.Conn.Status.code(404)
  end

  def serve_file? _conn do
    Megauni.dev?
  end

  def api_request? conn do
    Megauni.Router.API.api_request? conn
  end

  def browser_request? conn do
    !api_request?(conn)
  end

  def to_accepts conn do
    Map.get(conn, :req_headers)["accept"]
    |> String.split(";")
    |> List.first
    |> String.split(",")
    |> Enum.map(&(Plug.Conn.Utils.content_type &1))
    |> Enum.map(fn(x) ->
      case x do
        {:ok, _ignore, raw, _map} -> raw
        _ -> ""
      end
    end)
  end # === defp

  def find_accept conn, list do
    accepts = Map.get(conn, :req_headers)["accept"]
              |> String.split(";")
              |> List.first
              |> String.split(",")
              |> Enum.map(&(Plug.Conn.Utils.content_type &1))

    Enum.map list, fn(target) ->
      Enum.find(accepts, fn(x) ->
        case x do
          {:ok, _ignore, raw, _map} ->
            (is_binary(target) && target == raw) || raw =~ target
          _ -> false
        end
      end)
    end
  end # === defp

end # === Megauni



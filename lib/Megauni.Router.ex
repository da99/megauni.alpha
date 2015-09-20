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

  use Plug.Router

  if Mix.env == :dev do
    use Plug.Debugger
    plug Log.Debug
    plug Megauni.File.Static, at: "/", from: "/apps/megauni.html/Public"
  end

  plug :match
  plug :dispatch

  # get "/" do
    # conn
    # |> put_resp_content_type("text/plain")
    # |> send_resp(200, "Hello world")
  # end

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Not found")
  end

end # === Megauni




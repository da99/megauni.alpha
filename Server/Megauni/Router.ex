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

  defmacro __using__(opts) do
    quote do
      import Megauni.Router, only: :macros
      use Plug.Router, unquote(opts)
    end
  end # === defmacro

  @doc """
  Defaults to: www :get, "/path", opts

  ## Examples

      www "/home" do
      end

      www "/:home" when home == "home" do
      end

  """
  defmacro www path, opts do
    quote do
      unquote(:www)(unquote(:get), unquote(path), unquote(opts))
    end
  end

  # NOTE:
  # To match with the :get macro from Plug.Builder,
  # `:contents \\ []` would be added to the arguments.
  # It has been left out since it was never used.
  defmacro www meth, path, opts do
    {body, opts} = Keyword.pop(opts, :do)

    quote do
      unquote(meth)(unquote(path), unquote(opts)) do
        var!(conn) = var!(conn) |> Session.Router.logged_in!

        if Megauni.Router.fulfilled?(var!(conn)) do
          var!(conn)
        else
          unquote(body)
        end
      end
    end
  end # === defmacro

  # === Helpers/Miscell.: ==========================================

  @static Path.expand("../megauni.html/Public")

  def static_path do
    @static
  end

  def static_path path do
    Path.join @static, path
  end

  def fulfilled? conn do
    Map.get(conn, :state) == :sent ||
    !is_nil(Map.get conn, :status) ||
    Map.get(conn, :halted)
  end

  def no_404? conn do
    Map.get(conn, :status) != Plug.Conn.Status.code(404)
  end

  def serve_file? _conn do
    Megauni.dev?
  end

  def api_request? conn do
    Megauni.API.request? conn
  end

  def browser_request? conn do
    !api_request?(conn)
  end

  @doc """
    respond_halt conn, ["error", [err_name, "[msg]"]]
  """
  def respond_halt(conn, status, o = ["error", [err_name, msg]]) when is_binary(msg) do
    accepts = conn |> to_accepts
    cond do
      "html" in accepts ->
        conn |> respond_halt(status, :html, msg)

      "json" in accepts ->
        conn |> respond_halt(status, :json, Poison.encode!(o))

      true ->
        conn |> respond_halt(status, :text, "Error: #{err_name}: #{msg}")
    end
  end

  @doc """
    respond_halt conn, 200, "...."
  """
  def respond_halt(conn, status, content) when (is_number(status) or is_binary(status)) and is_binary(content) do
    conn |> respond_halt(status, :text, content)
  end

  @doc """
    respond_halt conn, "...."
  """
  def respond_halt(conn, content) when is_binary(content) do
    conn |> respond_halt(200, content)
  end

  @doc """
    respond_halt conn, 200, :html, "...."
  """
  def respond_halt(conn, status, raw_type, content) when is_binary(content) do
    conn
    |> Plug.Conn.put_resp_content_type(raw_type |> to_content_type)
    |> Plug.Conn.send_resp(status, content)
    |> Plug.Conn.halt
  end

  def to_content_type(name) when is_atom(name) do
    case name do
      :text -> "text/plain"
      :html -> "text/html"
      :json -> "application/json"
    end
  end # === def to_content_type

  def to_content_type(name) when is_binary(name) do
    name
  end # === def to_content_type(name) when is_binary(name)

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







defmodule Megauni.Static.Router do
  require Logger

  def init opts do
    Plug.Static.init opts
  end

  def call conn,  opts = {_at, from, _gzip, _qs_cache, _et_cache, _only, _headers} do
    path_info = Map.get(conn,:path_info)

    file_path = path_info
                |> Enum.join("/")
                |> Path.expand(from)

    if !file?(file_path) do
      file_path = Path.join(file_path, "index.html")
      if file?(file_path) do
        conn = Map.put conn, :path_info, path_info ++ ["index.html"]
        conn = Map.put conn, :request_path, "/#{Enum.join Map.get(conn, :path_info), "/"}"
      end
    end

    if file?(file_path) do
      conn = Plug.Static.call conn, opts
    end

    conn
  end

  defp file? path do
    !File.dir?(path) && File.exists?(path)
  end

  def not_found(conn, _) do
    if Megauni.Router.fulfilled?(conn) do
      conn
    else
      if Megauni.dev? do
        Logger.debug "!!! === #{inspect Map.get(conn, :path_info)}"
      end
      Plug.Conn.send_resp(conn, 404, "File not found")
    end
  end

end # === defmodule Megauni.Static.Routes

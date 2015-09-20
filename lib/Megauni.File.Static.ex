


defmodule Megauni.File.Static do
  @moduledoc """
  A plug for serving static assets, customized from Plug.Static.
  This is meant to be used only for :dev environment.
  In :prod (production), you would use NGINX to serve ALL static
  files.

  Do a `diff` to see the changes I made. Basically:
     /          -> /index.html
     /path/path -> /path/path/index.html (if /path/path is not a file.)
  """

  @behaviour Plug
  @allowed_methods ~w(GET HEAD)

  import Plug.Conn
  alias Plug.Conn

  # In this module, the `:prim_info` Erlang module along with the `:file_info`
  # record are used instead of the more common and Elixir-y `File` module and
  # `File.Stat` struct, respectively. The reason behind this is performance: all
  # the `File` operations pass through a single process in order to support node
  # operations that we simply don't need when serving assets.

  require Record
  Record.defrecordp :file_info, Record.extract(:file_info, from_lib: "kernel/include/file.hrl")

  defmodule InvalidPathError do
    defexception message: "invalid path for static asset", plug_status: 400
  end

  def init(opts) do
    at    = Keyword.fetch!(opts, :at)
    from  = Keyword.fetch!(opts, :from)
    gzip  = Keyword.get(opts, :gzip, false)
    only  = Keyword.get(opts, :only, nil)

    qs_cache = Keyword.get(opts, :cache_control_for_vsn_requests, "public, max-age=31536000")
    et_cache = Keyword.get(opts, :cache_control_for_etags, "public")
    headers  = Keyword.get(opts, :headers, %{})

    from =
      case from do
        {_, _} -> from
        _ when is_atom(from) -> {from, "priv/static"}
        _ when is_binary(from) -> from
        _ -> raise ArgumentError, ":from must be an atom, a binary or a tuple"
      end

    {Plug.Router.Utils.split(at), from, gzip, qs_cache, et_cache, only, headers}
  end

  def call(conn = %Conn{method: meth}, {at, from, gzip, qs_cache, et_cache, only, headers})
      when meth in @allowed_methods do
    # subset/2 returns the segments in `conn.path_info` without the
    # segments at the beginning that are shared with `at`.
    segments = subset(at, conn.path_info) |> Enum.map(&URI.decode/1)

    if 0 === length(segments) do
      segments = ["index.html"]
    end

    cond do
      not allowed?(only, segments) ->
        conn
      invalid_path?(segments) ->
        raise InvalidPathError
      true ->
        path = path(from, segments)

        results = file_encoding(conn, path, gzip)
        if tuple_size(results) === 2 do
          segments = List.insert_at(segments, -1, 'index.html')
          path = path(from, segments)
          results = file_encoding(conn, path, gzip)
        end

        serve_static(results, segments, gzip, qs_cache, et_cache, headers)
    end
  end

  def call(conn, _opts) do
    conn
  end

  defp allowed?(_only, []),   do: false
  defp allowed?(nil, _list),  do: true
  defp allowed?(only, [h|_]), do: h in only

  defp serve_static({:ok, conn, file_info, path}, segments, gzip, qs_cache, et_cache, headers) do
    case put_cache_header(conn, qs_cache, et_cache, file_info) do
      {:stale, conn} ->
        content_type = segments |> List.last |> Plug.MIME.path

        conn
        |> maybe_add_vary(gzip)
        |> put_resp_header("content-type", content_type)
        |> merge_resp_headers(headers)
        |> send_file(200, path)
        |> halt
      {:fresh, conn} ->
        conn
        |> send_resp(304, "")
        |> halt
    end
  end

  defp serve_static({:error, conn}, _segments, _gzip, _qs_cache, _et_cache, _headers) do
    conn
  end

  defp maybe_add_vary(conn, true) do
    # If we serve gzip at any moment, we need to set the proper vary
    # header regardless of whether we are serving gzip content right now.
    # See: http://www.fastly.com/blog/best-practices-for-using-the-vary-header/
    update_in conn.resp_headers, &[{"vary", "Accept-Encoding"}|&1]
  end

  defp maybe_add_vary(conn, false) do
    conn
  end

  defp put_cache_header(%Conn{query_string: "vsn=" <> _} = conn, qs_cache, _et_cache, _file_info)
      when is_binary(qs_cache) do
    {:stale, put_resp_header(conn, "cache-control", qs_cache)}
  end

  defp put_cache_header(conn, _qs_cache, et_cache, file_info) when is_binary(et_cache) do
    etag = etag_for_path(file_info)

    conn =
      conn
      |> put_resp_header("cache-control", et_cache)
      |> put_resp_header("etag", etag)

    if etag in get_req_header(conn, "if-none-match") do
      {:fresh, conn}
    else
      {:stale, conn}
    end
  end

  defp put_cache_header(conn, _, _, _) do
    {:stale, conn}
  end

  defp etag_for_path(file_info) do
    file_info(size: size, mtime: mtime) = file_info
    {size, mtime} |> :erlang.phash2() |> Integer.to_string(16)
  end

  defp file_encoding(conn, path, gzip) do
    path_gz = path <> ".gz"

    cond do
      gzip && gzip?(conn) && (file_info = regular_file_info(path_gz)) ->
        {:ok, put_resp_header(conn, "content-encoding", "gzip"), file_info, path_gz}
      file_info = regular_file_info(path) ->
        {:ok, conn, file_info, path}
      true ->
        {:error, conn}
    end
  end

  defp regular_file_info(path) do
    case :prim_file.read_file_info(path) do
      {:ok, file_info(type: :regular) = file_info} ->
        file_info
      _ ->
        nil
    end
  end

  defp gzip?(conn) do
    gzip_header? = &String.contains?(&1, ["gzip", "*"])
    Enum.any? get_req_header(conn, "accept-encoding"), fn accept ->
      accept |> Plug.Conn.Utils.list() |> Enum.any?(gzip_header?)
    end
  end

  defp path({app, from}, segments) when is_atom(app) and is_binary(from),
    do: Path.join([Application.app_dir(app), from|segments])
  defp path(from, segments),
    do: Path.join([from|segments])

  defp subset([h|expected], [h|actual]),
    do: subset(expected, actual)
  defp subset([], actual),
    do: actual
  defp subset(_, _),
    do: []

  defp invalid_path?([h|_]) when h in [".", "..", ""], do: true
  defp invalid_path?([h|t]), do: String.contains?(h, ["/", "\\", ":"]) or invalid_path?(t)
  defp invalid_path?([]), do: false
end

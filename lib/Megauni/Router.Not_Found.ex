
defmodule Megauni.Router.Not_Found do


  def init [html: path_to_file] do
    File.read! path_to_file
  end

  def call conn, html_404 do
    accepts = Megauni.Router.to_accepts(conn)

    cond do
      "html" in accepts ->
        conn
        |> Plug.Conn.put_resp_content_type("text/html")
        |> Plug.Conn.send_resp(404, html_404)

      "json" in accepts ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(404, Poison.encode! %{"resp" => ["error", "Not found"]})

      true ->
        conn
        |> Plug.Conn.put_resp_content_type("text/plain")
        |> Plug.Conn.send_resp(404, "Not found!")
    end

  end


end # === defmodule Megauni.Router.Not_Found

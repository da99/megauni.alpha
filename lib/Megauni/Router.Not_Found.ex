
defmodule Megauni.Router.Not_Found do


  def init [from: static] do
    File.read!("#{static}/404.html")
  end

  def call conn, html_404 do
    [is_html, is_json] = find_accept(conn, [~r/html/, ~r/json/])

    cond do
      is_html ->
        conn
        |> Plug.Conn.put_resp_content_type("text/html")
        |> Plug.Conn.send_resp(404, html_404)

      is_json ->
        conn
        |> Plug.Conn.put_resp_content_type("application/x-json")
        |> Plug.Conn.send_resp(404, Poison.encode! %{"resp" => ["error", "Not found"]})

      true    ->
        conn
        |> Plug.Conn.put_resp_content_type("text/plain")
        |> Plug.Conn.send_resp(404, "Not found!")
    end

  end

  defp find_accept conn, list do
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
  end

end # === defmodule Megauni.Router.Not_Found

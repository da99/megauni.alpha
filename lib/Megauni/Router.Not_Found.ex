
defmodule Megauni.Router.Not_Found do

  def init [html: path_to_file] do
    File.read! path_to_file
  end

  def call conn, html_404 do
    if Map.get(conn, :state) == :sent do
      if Megauni.dev? do
        require Logger
        Logger.warn("=== Response already sent: skipping #{__MODULE__} plug")
      end
      Plug.Conn.halt conn
    else
      send_response conn, html_404
    end
  end # === def call

  defp send_response conn, html_404 do
    accepts = Megauni.Router.to_accepts(conn)

    cond do
      "html" in accepts ->
        conn
        |> Megauni.Router.respond_halt("text/html", 404, html_404)


      "json" in accepts ->
        conn
        |> Megauni.Router.respond_halt(
        "application/json",
        404,
        Poison.encode! %{"resp" => ["error", "Not found"]}
        )

      true ->
        conn
        |> Megauni.Router.respond_halt("text/plain", 404, "Not found!")
    end
  end # === def respond


end # === defmodule Megauni.Router.Not_Found

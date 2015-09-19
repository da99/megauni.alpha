
defmodule Megauni.Router do

  use Plug.Router

  if Mix.env == :dev do
    use Plug.Debugger
    plug Plug.Logger
  end

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello world")
  end

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Not found")
  end

end # === Megauni




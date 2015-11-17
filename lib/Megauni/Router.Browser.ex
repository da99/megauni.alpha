
defmodule Megauni.Router.Browser do

  use Plug.Router

  plug :match
  plug :dispatch

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Not found!")
  end

end # === defmod

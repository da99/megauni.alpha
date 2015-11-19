
defmodule Card.Router do

  use Plug.Router

  plug :match
  plug Megauni.Browser.Session
  plug :dispatch

  match _ do
    conn
  end

end # === defmodule Card.Router

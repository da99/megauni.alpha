
defmodule Megauni.Router.Browser do

  use Plug.Router

  plug :match
  plug :dispatch

  match _ do
    conn
  end

end # === defmod

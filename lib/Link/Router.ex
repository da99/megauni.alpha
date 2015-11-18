

defmodule Link.Router do

  use Plug.Router
  plug :match
  plug :dispatch

  match _ do
    conn
  end

end # === defmodule Link.Router

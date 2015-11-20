

defmodule Link.Routes do

  use Plug.Router

  plug :match
  plug Megauni.Browser.Session
  plug :dispatch

  match _ do
    conn
  end

end # === defmodule Link.Routes

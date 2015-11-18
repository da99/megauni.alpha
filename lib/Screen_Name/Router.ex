
defmodule Screen_Name.Router do
  use Plug.Router
  plug :match
  plug :dispatch

  match _ do
    conn
  end
end # === defmodule Screen_Name.Router

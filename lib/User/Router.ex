
defmodule User.Router do

  use Plug.Router

  plug :match
  plug Megauni.Browser.Session
  plug :dispatch

  get "/user" do
    conn
    |> Megauni.Router.respond_halt(200, "yo yo: user")
  end

  match _ do
    conn
  end

end # === defmodule User.Router

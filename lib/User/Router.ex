
defmodule User.Router do

  use Plug.Router
  plug :match
  plug :dispatch

  # def call conn, _opts do
    # conn
  # end

  get "/user" do
    conn
    |> Megauni.Router.respond_halt(200, "yo yo: user")
  end

  match _ do
    conn
  end

end # === defmodule User.Router

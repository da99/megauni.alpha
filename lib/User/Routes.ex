


defmodule User.Routes do

  use Megauni.Router
  plug :match
  plug :dispatch

  get "/:user"  when user == "user"   do
    conn
    |> Megauni.Router.respond_halt(200, "yo yo: user")
  end

  match  _ do
    conn
  end

end # === defmodule User.Routes




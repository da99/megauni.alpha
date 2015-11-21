


defmodule User.Routes do

  alias Megauni.Router,  as: R

  use Megauni.Router
  plug :match
  plug :dispatch

  www "/user"  do
    conn
    |> R.respond_halt(200, "yo yo: user")
  end

  match  _ do
    conn
  end

end # === defmodule User.Routes




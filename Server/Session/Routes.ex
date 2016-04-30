
defmodule Session.Routes do
  use Megauni.Router

  plug :match
  plug :dispatch

  www :post, "/session/create" do
    raise "Not done."
  end

  www :get, "/session/delete" do
    raise "Not done."
  end

  match _ do
    conn
  end
end # === defmodule Session.Routes

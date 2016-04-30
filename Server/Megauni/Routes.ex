

defmodule Megauni.Routes do

  use Plug.Builder

  if Megauni.dev? do
    use Plug.Debugger
    plug Log.Debug
    plug Megauni.Static.Router, at: "/", from: Megauni.Router.static_path
  end

  plug Megauni.API.Routes
  plug Megauni.Browser.Routes

  plug Megauni.Not_Found.Routes, html: Megauni.Router.static_path("/404.html")

end # === defmodule Megauni.Routes

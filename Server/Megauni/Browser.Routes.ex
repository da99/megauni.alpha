
defmodule Megauni.Browser.Routes do

  use Plug.Builder

  plug Session.Routes
  plug User.Routes
  plug Screen_Name.Routes
  plug Link.Routes
  plug Card.Routes

end # === defmod

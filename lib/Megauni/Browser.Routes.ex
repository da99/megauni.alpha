
defmodule Megauni.Browser.Routes do

  use Plug.Builder

  plug User.Routes
  plug Screen_Name.Routes
  plug Log_In.Routes
  plug Link.Routes
  plug Card.Routes

end # === defmod

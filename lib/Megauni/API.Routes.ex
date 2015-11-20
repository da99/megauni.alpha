
defmodule Megauni.API do

  def request?(conn) do
    false
  end

end # === defmodule Megauni.API

defmodule Megauni.API.Routes do

  def init(opts) do
    opts
  end

  def call conn, _opts do
    if Megauni.API.request?(conn) do
      raise "Not implemented"
    else
      conn
    end
  end

end # === defmod


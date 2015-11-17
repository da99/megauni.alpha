
defmodule Megauni.Router.API do

  def api_request?(conn) do
    false
  end

  def init(opts) do
    opts
  end

  def call conn, _opts do
    if api_request?(conn) do
      raise "Not implemented"
    else
      conn
    end
  end

end # === defmod


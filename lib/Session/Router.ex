
defmodule Session.Router do


  def logged_in? conn do
    # plug Megauni.Browser.Session
    false
  end

  def logged_in! conn do
    if logged_in?(conn) do
      conn
    else
      conn
      |> Megauni.Router.respond_halt(200, ["error", ["user_error", "You are not logged in."]])
    end
  end

end # === defmodule Session.Router

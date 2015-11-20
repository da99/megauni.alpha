
defmodule Session.Router do

  @plug_sesson_opts Plug.Session.init(
    store:           :cookie,
    key:             "_megauni_session",
    encryption_salt: Application.get_env(:megauni, :session_encrypt_salt),
    signing_salt:    Application.get_env(:megauni, :session_sign_salt),
    key_length:      64
  )

  def put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, Application.get_env(:megauni, :session_secret_base)
  end

  def get_session conn do
    Plug.Session.call(conn, @plug_sesson_opts)
  end

  @doc """
    Make sure to: `conn = #{__MODULE__}.get_session(conn)`
    before using :logged_in?
  """
  def logged_in? conn do
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

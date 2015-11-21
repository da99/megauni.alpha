
defmodule Session.Router do

  @key_has_been_setup :has_session_been_setup?

  @plug_sesson_opts Plug.Session.init(
    store:           :cookie,
    key:             "_megauni_session",
    domain:          Application.get_env(:megauni, :host),
    max_age:         nil,
    path:            "/",
    http_only:       true,
    secure:          !Megauni.dev?,
    encryption_salt: Application.get_env(:megauni, :session_encrypt_salt),
    signing_salt:    Application.get_env(:megauni, :session_sign_salt),
    key_length:      64
  )

  defp setup? conn do
    Map.get(conn.private, @key_has_been_setup, false)
  end

  @doc """
    Based on Plug.Conn.fetch_session:
    https://github.com/elixir-lang/plug/blob/v1.0.2/lib/plug/conn.ex#L755
  """
  defp setup conn do
    if !setup?(conn) do
      conn = conn
              |> Map.put(:secret_key_base, Application.get_env(:megauni, :session_secret_base))
              |> Plug.Session.call(@plug_sesson_opts)
              |> Plug.Conn.fetch_session
              |> Plug.Conn.put_private(@key_has_been_setup, true)
    end

    conn
  end

  def get conn, key do
    conn |> setup |> Plug.Conn.get_session(key)
  end

  def put conn, key, val do
    conn |> setup |> Plug.Conn.put_session(key, val)
  end

  def logged_in? conn do
    conn |> get(:current_user)
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

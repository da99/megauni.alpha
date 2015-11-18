
defmodule Megauni.Router.Browser do

  use Plug.Builder

  plug :put_secret_key_base
  def put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, Application.get_env(:megauni, :session_secret_base)
  end

  plug Plug.Session,
    store:           :cookie,
    key:             "_megauni_session",
    encryption_salt: Application.get_env(:megauni, :session_encrypt_salt),
    signing_salt:    Application.get_env(:megauni, :session_sign_salt),
    key_length:      64

  plug User.Router
  plug Screen_Name.Router
  plug Log_In.Router
  plug Link.Router
  plug Card.Router

end # === defmod

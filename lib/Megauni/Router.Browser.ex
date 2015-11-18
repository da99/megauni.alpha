
defmodule Megauni.Router.Browser do

  use Plug.Router

  plug :put_secret_key_base
  plug Plug.Session,
    store:           :cookie,
    key:             "_megauni_session",
    encryption_salt: Application.get_env(:megauni, :session_encrypt_salt),
    signing_salt:    Application.get_env(:megauni, :session_sign_salt),
    key_length:      64

  plug :match
  plug :dispatch

  match _ do
    conn
  end

  def put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, Application.get_env(:megauni, :session_secret_base)
  end

end # === defmod

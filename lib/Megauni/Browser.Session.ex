
defmodule Megauni.Browser.Session do

  use Plug.Builder

  plug Plug.Session,
    store:           :cookie,
    key:             "_megauni_session",
    encryption_salt: Application.get_env(:megauni, :session_encrypt_salt),
    signing_salt:    Application.get_env(:megauni, :session_sign_salt),
    key_length:      64

end # === defmodule Megauni.Browser.Session

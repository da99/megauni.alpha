
use Mix.Config

is_dev = System.get_env("IS_DEV")

config :comeonin, :bcrypt_log_rounds,         (is_dev && 4) || 13
config :megauni,  :port,                      ((System.get_env("PORT") || "4567") |> String.to_integer)
config :megauni,  :session_secret_base,       System.get_env("SESSION_SECRET") || raise("SESSION_SECRET not set")
config :megauni,  :session_encrypt_salt,      System.get_env("ENCRYPT_SALT")   || raise("ENCRYPT_SALT not set")
config :megauni,  :session_sign_salt,         System.get_env("SIGN_SALT")     || raise("SIGN_SALT not set")
config :megauni,  :host,                      (is_dev && "localhost") || "www.megauni.com"


if is_dev do
  config :logger, :console, level: :debug, format: "[$level] $message\n"
else
  config :logger, :console, level: :warn,  format: "$time [$level] $metadata$message\n"
end

config :megauni, Megauni.Repos.Main,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME"),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  hostname: "localhost"



use Mix.Config


is_dev        = System.get_env("IS_DEV")
is_www_server = System.get_env("IS_RUNNING_WWW_SERVER")

config :comeonin, :bcrypt_log_rounds, (is_dev && 4) || 13
config :megauni, :port, ((System.get_env("PORT") || "4567") |> String.to_integer)

if is_dev && is_www_server do
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


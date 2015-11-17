
use Mix.Config

config :megauni, :port, ((System.get_env("PORT") || "4567") |> String.to_integer)

is_dev = System.get_env("IS_DEV")
is_www_server = System.get_env("IS_RUNNING_WWW_SERVER")

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

if is_dev do
  config :comeonin, :bcrypt_log_rounds, 4
else
  config :comeonin, :bcrypt_log_rounds, 13
end

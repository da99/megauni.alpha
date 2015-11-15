
use Mix.Config

config :logger, :console, format: "$time $metadata$message\n"

is_dev = System.get_env("IS_DEV")
is_www_server = System.get_env("IS_RUNNING_WWW_SERVER")

if is_dev && is_www_server do
  config :logger, level: :info
else
  config :logger, level: :warn
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


use Mix.Config

config :logger, :console, format: "$time $metadata$message\n"
config :logger, level: :warn

config :megauni, Megauni.Repos.Main,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME"),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  hostname: "localhost"

if System.get_env("IS_DEV") do
  # config :logger, level: :warn
  config :comeonin, :bcrypt_log_rounds, 4
else
  config :comeonin, :bcrypt_log_rounds, 13
end

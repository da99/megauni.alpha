
defmodule Megauni do
  use Application

  def dev? do
    System.get_env("IS_DEV")
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        supervisor(__MODULE__, [], function: :run_http_adapter),
        supervisor(Megauni.Repos.Main, [])
      ], [
        strategy: :one_for_one,
        name:     Megauni.Supervisor
      ]
    )
  end

  def run_http_adapter do
    require Logger

    port = Application.get_env(:megauni, :port)

    server = Plug.Adapters.Cowboy.http(
      Megauni.Routes, [], port: port
    )

    case server do
      {:ok, _} ->
        Logger.debug("=== Server is ready on port: #{port}")
      {:error, err} ->
        Logger.error("=== Error in starting server:")
        Logger.error(inspect err)
    end

    server
  end

  # === From:
  # === 
  def random_string length do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

end # === defmodule Megauni


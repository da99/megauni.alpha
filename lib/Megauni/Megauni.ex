
defmodule Megauni do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      worker(__MODULE__, [], function: :run_http_adapter),
      worker(Megauni.Repos.Main, [])
    ], [
      strategy: :one_for_one,
      name:     Megauni.Supervisor
    ])
  end

  def run_http_adapter do
    require Logger

    port = Application.get_env(:megauni, :port)

    server = Plug.Adapters.Cowboy.http(
      Megauni.Router, [], port: port
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

end # === defmodule Megauni


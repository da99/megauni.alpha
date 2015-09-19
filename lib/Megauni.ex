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
    {:ok, _} = Plug.Adapters.Cowboy.http Megauni.Router, []
  end

end # === defmodule Megauni

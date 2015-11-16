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
    {:ok, _} = Plug.Adapters.Cowboy.http Megauni.Router, [], port: port
  end

  def port do
    Application.get_env(:megauni, :main)[:port]
    |> String.to_integer
  end

end # === defmodule Megauni


defmodule Mix.Tasks.Megauni do

  defmodule Server do
    use Mix.Task
    def run(args) do
      Mix.Task.run "run", args
    end # === def run(_)
  end # === defmodule Run

end # === defmodule Mix.Tasks.Megauni

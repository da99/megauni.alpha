
defmodule Mix.Tasks.Megauni do

  defmodule Server do

    use Mix.Task

    def run(args) do
      Mix.Task.run "run", args
    end # === def run(_)

  end # === defmodule Run

end # === defmodule Mix.Tasks.Megauni

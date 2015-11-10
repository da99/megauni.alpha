

defmodule Main do

  import DA_3001, only: :functions

  def modules do
    "lib/*/specs/funcs.ex*"
    |> to_file_paths
    |> split("/")
    |> pluck(1)
    |> map(&(:"Elixir.#{&1}.Spec_Funcs"))
  end

  def models do
    if Enum.empty?(System.argv) do
      "bin/megauni"
      |> Path.expand
      |> System.cmd(["model_list"])
      |> first
      |> String.strip
      |> String.split
    else
      System.argv
    end
  end # === def models

  def files do
    files = Enum.reduce models, [], fn(mod, acc) ->
      cond do
        File.exists?(mod)  -> acc ++ [mod]
        mod =~ ~r/[\*|\/]/ -> acc ++ Path.wildcard("lib/#{mod}.json")
        true               -> acc ++ Path.wildcard("lib/#{mod}/specs/*.json")
      end
    end

    if Enum.empty?(files) do
      Process.exit self, "!!! No specs found: #{inspect System.argv}. Exiting..."
    end

    files
  end # === def files

  def syntax_check? do
    ["syntax"] == System.argv
  end

  def run do
    if Main.syntax_check? do
      nil # === do nothin
    else
      JSON_Applet.Spec.run_files(
      Main.files,
      Main.modules
      )
    end
  end

end # === defmodule Main

Main.run




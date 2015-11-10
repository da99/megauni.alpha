

models = if Enum.empty?(System.argv) do
  {raw, _exit} = System.cmd Path.expand("bin/megauni"), ["model_list"]
  raw |> String.strip |> String.split
else
  System.argv
end

files = Enum.reduce models, [], fn(mod, acc) ->
   cond do
     File.exists?(mod) ->
       acc ++ [mod]
     mod =~ ~r/[\*|\/]/ ->
       acc ++ Path.wildcard("lib/#{mod}.json")
     true ->
       acc ++ Path.wildcard("lib/#{mod}/specs/*.json")
   end
end


if Enum.empty?(files) do
  Process.exit self, "!!! No specs found: #{inspect System.argv}. Exiting..."
end

spec_funcs = "lib/*/specs/funcs.ex*"
              |> Path.wildcard
              |> Enum.map(&(String.split &1, "/"))
              |> Enum.map(&(Enum.at &1, 1))
              |> Enum.map(&(:"Elixir.#{x}.Spec_Funcs"))

JSON_Applet.Spec.run_files(
  files,
  [
    Screen_Name.Spec_Funcs,
    User.Spec_Funcs,
    Link.Spec_Funcs,
    Log_In.Spec_Funcs,
    Megauni.Spec_Funcs
  ]
)





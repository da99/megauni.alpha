

run_file = fn(path) ->
  IO.puts ""
  IO.puts "file: #{IO.ANSI.bright}#{path}#{IO.ANSI.reset}"
  json = File.read!(path)
          |> Poison.decode!
  IO.inspect json
end

{raw, _exit} = System.cmd Path.expand("bin/megauni"), ["model_list"]
models       = raw |> String.strip |> String.split |> Enum.join ","

files = Path.wildcard("lib/{#{models}}/specs/*.json")
Enum.each(files, &(run_file.(&1)))





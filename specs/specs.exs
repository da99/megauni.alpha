
format_num = fn(num) ->
  space = String.duplicate(" ", 2 - String.length to_string(num))
  "#{space}#{num}"
end

run_desc = fn(task, meta) ->
  %{"desc"=>desc} = task
  IO.puts "\n#{IO.ANSI.yellow}#{desc}#{IO.ANSI.reset}"
  %{:func=>desc, :it_count => meta.it_count}
end

compile = fn(x, funcs) ->
  cond do
    is_binary(x) ->
    is_map(x) ->
    is_list(x) ->
  end
end # === compile

run_it = fn(task, meta) ->
  %{"it"=>it, "input"=>raw_input,"output"=>raw_output} = task
  input = compile.(raw_input, funcs)
  IO.puts "#{format_num.(meta.it_count)}) #{it}#{IO.ANSI.reset}"
  %{:func=>meta.func, :it_count => meta.it_count + 1, :stack => [], :vars => %{}, }
end

run_file = fn(path) ->
  IO.puts ""
  IO.puts "file: #{IO.ANSI.bright}#{path}#{IO.ANSI.reset}"
  json = File.read!(path)
          |> Poison.decode!
  Enum.reduce(json, %{it_count: 1, func: nil}, fn(task, meta) ->
    case task do
      %{"desc"=>desc} -> run_desc.(task, meta)
      %{"it"  =>it}   -> run_it.(task, meta)
      _               -> raise "Don't know what to do with: #{inspect task}"
    end # === cond
  end)
end # === run_file

{raw, _exit} = System.cmd Path.expand("bin/megauni"), ["model_list"]
models       = raw |> String.strip |> String.split |> Enum.join ","

files = Path.wildcard("lib/{#{models}}/specs/*.json")
Enum.each(files, &(run_file.(&1)))





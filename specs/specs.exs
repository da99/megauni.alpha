
defmodule JSON_Spec do

  def format_num(num) do
    space = String.duplicate " ", 2 - String.length(to_string(num))
    "#{space}#{num}"
  end

  def run_file(path, env) do
    json = File.read!(path) |> Poison.decode!

    IO.puts "\nfile: #{IO.ANSI.bright}#{path}#{IO.ANSI.reset}"

    Enum.reduce(json, Enum.into(%{:it_count=>1}, env), fn(task, env) ->
      case task do
        %{"desc"=>_desc} -> run_desc(task, env)
        %{"it"  =>_it}   -> run_it(task, env)
        _               -> raise "Don't know what to do with: #{inspect task}"
      end # === cond
    end)
  end # === run_file

  def run_desc(task, env) do
    %{"desc"=>desc} = task
    IO.puts "\n#{IO.ANSI.yellow}#{desc}#{IO.ANSI.reset}"
    Enum.into %{ :desc=>desc }, env
  end

  def run_it(task, env) do
    %{"it"=>it, "input"=>raw_input,"output"=>raw_output} = task
    {input, env}  = compile(raw_input, env)
    {expected, env} = compile(raw_output, env)

    num    = "#{format_num(env.it_count)})"
    bright = IO.ANSI.bright
    reset  = IO.ANSI.reset
    red    = "#{bright}#{IO.ANSI.red}"

    # === Run the input:
    {actual, env} = env[env[:desc]].(input, env)

    is_match = Enum.reduce(actual, true, fn({k,v}, acc) ->
      if v do
        expected[k] == v
      else
        v
      end
    end)

    if is_match do
      IO.puts "#{bright}#{IO.ANSI.green}#{num}#{reset} #{it}"
    else
      IO.puts "#{bright}"
      IO.puts "#{red}#{num}#{reset}#{bright} #{it}"
      IO.puts "#{red}#{inspect actual} !== #{reset}#{bright}#{inspect expected}"
    end
    IO.puts reset
    Enum.into %{ :it_count => env.it_count + 1 }, env
  end

  def run_list(_x, _env) do
    raise "run_list: need to be implemented"
  end

  def canon_key(x) do
    x |> String.strip |> (&(Regex.replace(~r/\s+/, &1," "))).()
  end

  def compile(x, env) do

    cond do
      is_binary(x) -> # === See if string is a var or func call.
        name = canon_key(x)
        cond do
          Map.has_key?(env, name) && !is_function(env[name]) ->
            {env[name], env}
          Map.has_key?(env, name) ->
            {_val, _new_env} = env[name].(env)
          true -> # === Check for "key.key.key"
            [ key | pieces ] = String.split(name, ".")
            if Map.has_key?(env, key) do
              fin = Enum.reduce(pieces, env[key], fn(v, acc) ->
                acc[v]
              end)
              {fin, env}
            else # === send the original, instead of the canonized
              {x, env}
            end
        end # === cond

      is_map(x) ->
        result = Enum.reduce x, %{:map=>%{}, :env=>env}, fn({k,v}, pair) ->
          {new_v, new_e} = compile(v, env)
          Enum.into(
            %{:map=>Map.put(pair.map, k, new_v), :env=>new_e},
            pair
          )
        end
        {result.map, result.env}

      is_list(x) ->
        run_list(x, env) |> List.last

      true ->
        raise "Don't know what to do with: #{inspect x}"
    end # === cond
  end # === compile

end # === defmodule JSON_Spec


{raw, _exit} = System.cmd Path.expand("bin/megauni"), ["model_list"]
models       = raw |> String.strip |> String.split |> Enum.join ","

files = Path.wildcard("lib/{#{models}}/specs/*.json")
env = %{

  "create: rand.screen_name" => fn(env) ->
    {_mega, sec, micro} = :erlang.timestamp
    sn = "SN_#{sec}_#{micro}"
    { sn, Map.put(env, "screen_name", sn) }
  end,

  "Screen_Name.create" => fn(data, env) ->
    result = Screen_Name.create data
    case result do
      %{"error" => msg} ->
        {%{"error"=>msg}, Map.put(env, "error", msg)}
      %{"screen_name"=>sn} ->
        {result, Map.put(env, "sn", result)}
    end
  end
}

Enum.each(files, &(JSON_Spec.run_file(&1, env)))





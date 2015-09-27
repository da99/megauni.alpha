
defmodule JSON_Spec do
  @docmodule """
  Specs to be written:
  1) uses a new env for "IT"
  2) uses a new env for "DESC"
  3) it compiles output AFTER running test
     REASON: "some variables are evaluated during/after IT run"
  4) Keys that partially exist evaluate to their original form:
     sn.data.id => sn.data => if sn exists, but not keys: data or id
  """

  def canon_key(x) do
    x |> String.strip |> (&(Regex.replace(~r/\s+/, &1," "))).()
  end

  def format_num(num) do
    space = String.duplicate " ", 2 - String.length(to_string(num))
    "#{space}#{num}"
  end

  def all_maps? list do
    !Enum.find list, fn(v) ->
      !is_map(v)
    end
  end

  @doc """
    Puts the name/val into the env.
    Also puts name_COUNTER/val into the env.

    Examples:
    iex> JSON_Spec.put(env, "sn", "my_name")
    %{"sn"=>"my_name", "sn_1"=>"my_name"}

    iex> JSON_Spec.put(env, "sn", "my_other_name")
    %{"sn"=>"my_other_name", "sn_2"=>"my_name"}

  """
  def put env, name, val do
    counter_key = "#{name}_counter"

    counter = if Map.has_key?(env, counter_key) do
      env[counter_key]+1
    else
      1
    end

    env
    |> Map.put(counter_key, counter)
    |> Map.put(name, val)
    |> Map.put("#{name}_#{env[counter]}", val)
  end

  def maps_match? actual, expected do
    if Enum.count(actual) < 1 do
      false
    else
      !Enum.find expected, fn({k,v}) ->
        actual[k] !== v
      end
    end
  end # === maps_match?

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

  def run_it(task, desc_env) do
    env = desc_env
    %{"it"=>it, "input"=>raw_input,"output"=>raw_output} = task
    {input, env}    = compile(raw_input, env)

    num    = "#{format_num(env.it_count)})"
    bright = IO.ANSI.bright
    reset  = IO.ANSI.reset
    red    = "#{bright}#{IO.ANSI.red}"

    # === Run the input:
    {actual, env} = run_input(input, env)

    # === Run the expected output:
    {expected, env} = compile(raw_output, env)

    if maps_match?(actual, expected) do
      IO.puts "#{bright}#{IO.ANSI.green}#{num}#{reset} #{it}"
    else
      IO.puts "#{bright}"
      IO.puts "#{red}#{num}#{reset}#{bright} #{it}"
      IO.puts "#{red}#{inspect actual} !== #{reset}#{bright}#{inspect expected}"
    end
    IO.puts reset
    Enum.into %{ :it_count => env.it_count + 1 }, desc_env
  end

  def run_input input, env do
    cond do

      is_map(input) ->
        env[env[:desc]].(input, env)

      is_list(input) ->
        Enum.reduce input, {nil, env}, fn(x, {_last, env}) ->
          env[env[:desc]].(x, env)
        end

      true -> raise "Don't know how to run: #{inspect input}"

    end # === cond
  end # === run_input

  def run_list(_x, _env) do
    raise "run_list: need to be implemented"
  end

  @doc """
    Examples:
    iex> JSON_Spec.compile("screen_name", env)
    iex> JSON_Spec.compile(%{"screen_name": "screen_name"}, env)
    iex> JSON_Spec.compile([%{}, %{}], env)
  """
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

      is_map(x) -> # === used to compile inputs and outputs
        result = Enum.reduce x, %{:map=>%{}, :env=>env}, fn({k,v}, pair) ->
          {new_v, new_e} = compile(v, env)
          Enum.into(
            %{:map=>Map.put(pair.map, k, new_v), :env=>new_e},
            pair
          )
        end
        {result.map, result.env}

      is_list(x) ->
        if all_maps?(x) do
          Enum.reduce x, {[], env}, fn(map, {list, env}) ->
            {map, env} = compile(map, env)
            {Enum.into([map], list), env}
          end
        else
          run_list(x, env)
        end

      true ->
        raise "Don't know what to do with: #{inspect x}"
    end # === cond
  end # === compile

end # === defmodule JSON_Spec


{raw, _exit} = System.cmd Path.expand("bin/megauni"), ["model_list"]
models       = raw |> String.strip |> String.split |> Enum.join ","

files = Path.wildcard("lib/{#{models}}/specs/*.json")
env = %{

  "rand screen_name" => fn(env) ->
    {_mega, sec, micro} = :erlang.timestamp
    sn = "SN_#{sec}_#{micro}"
    { sn, Map.put(env, "screen_name", sn) }
  end,

  "Screen_Name.create" => fn(data, env) ->
    result = Screen_Name.create data
    case result do
      %{"error" => msg} ->
        {%{"error"=>msg}, Map.put(env, "error", msg)}
      %{"screen_name"=>_sn} ->
        {result, JSON_Spec.put(env, "sn", result)}
    end
  end
}

Enum.each(files, &(JSON_Spec.run_file(&1, env)))







defmodule JSON_Spec do
  @docmodule """
  Specs to be written:
  1) uses a new env for "IT"
  2) uses a new env for "DESC"
  3) it compiles output AFTER running test
     REASON: "some variables are evaluated during/after IT run"
  4) Keys that partially exist evaluate to their original form:
     sn.data.id => sn.data => if sn exists, but not keys: data or id
  5) Compiles args when running list of commands:
     [ "func", {"key": "must be compiled"} ]
  6) Compiles non-arg tokens:
     [ ..., {"key": "this must be compiled"}]
  7) Adds counted var to map env: .put(env, key, val)
  8) Before all, Before each: Can only be one if "desc" has been
     used.
  """

  @core [

  desc: fn(task, env) ->
    %{"desc"=>desc} = task
    IO.puts "\n#{IO.ANSI.yellow}#{desc}#{IO.ANSI.reset}"
    Enum.into %{ :desc=>desc }, env
  end,

  before_all: fn(prog, env) ->
      if !desc do
        raise "desc not set for: before all"
      end
      run_prog(prog, env)
  end, # === def run_before_all

  after_each: fn(prog, env) ->
      if !desc do
        raise "desc not set for: after each"
      end
      Enum.into %{:after_each=> prog}, env
  end, # === def run_after_each

  it: fn(task, desc_env) ->
      env = desc_env
      %{"it"=>it, "input"=>raw_input,"output"=>raw_output} = task
      {actual, env}   = run_input(raw_input, env)
      {expected, env} = run_output(raw_output, env)

      num    = "#{format_num(env.it_count)})"
      bright = IO.ANSI.bright
      reset  = IO.ANSI.reset
      red    = "#{bright}#{IO.ANSI.red}"

      if maps_match?(actual, expected) do
        IO.puts "#{bright}#{IO.ANSI.green}#{num}#{reset} #{it}"
      else
        IO.puts "#{bright}"
        IO.puts "#{red}#{num}#{reset}#{bright} #{it}"
        IO.puts "#{red}#{inspect actual} !== #{reset}#{bright}#{inspect expected}"
      end
      IO.puts reset
      Enum.into %{ :it_count => env.it_count + 1 }, desc_env
  end,

  input: fn(input, env) ->
      cond do

        is_map(input) ->
          {input, env} = compile(input, env)
          env[env[:desc]].(input, env)

        is_list(input) && all_maps?(input) ->
          run_list_of_inputs(input, env)

        is_list(input) ->
          run_list(input, env)

          true -> raise "Don't know how to run: #{inspect input}"

      end # === cond
  end,  # === run_input

  output: fn(output, env) ->
      cond do
        is_map(output) ->
          compile(output, env)

        is_list(output) && !all_maps?(output) ->
          run_list(output, env)

        true ->
          raise "Don't know what to do with input/output: #{inspect output}"
      end
  end, # === def run_output


  ] # === @core

  def canon_key(x) do
    x |> String.strip
      |> (&(Regex.replace(~r/\s+/, &1," "))).()
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

  def all_funcs? map, list do
    Enum.all? Map.keys(map), fn(k) ->
      Enum.find_index(list, fn (x) -> x == k end)
    end
  end

  def all_funcs! map, list do
    Enum.each Map.keys(map), fn(k) ->
      if !Enum.find_index(list, fn (x) -> x == k end) do
        raise "func not found: #{inspect k}"
      end
    end
  end # === def all_funcs!

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
    |> Map.put("#{name}_#{counter}", val)
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

  def binary_to_atom s do
    if is_atom(s) do
      s
    else
      Regex.replace ~r/\s+/, String.strip(s), '_'
    end
  end

  def run_file(path, custom_funcs) do
    json = File.read!(path) |> Poison.decode!

    IO.puts "\nfile: #{IO.ANSI.bright}#{path}#{IO.ANSI.reset}"

    env        = Enum.into(%{:it_count=>1}, custom_funcs)
    core_names = Keyword.keys(@core)
    func_names = Map.keys(env)

    Enum.reduce json, env, fn(task, env) ->
      all_funcs! task, core_names

      # Map keys are not ordered, so we have to
      # run through each known func in order from
      # @core (a list)
      Enum.reduce core_names, env, fn(f_name, env) ->
        if Map.has_key?(task, f_name) do
          @core[f_name].(task[f_name], env)
        else
          env
        end
      end # === run through func names in proper order

    end

  end # === run_file

  def run_prog prog, env do
    cond do
      is_binary(prog) ->
        env[prog].( nil, env )

      is_list(prog) && !all_maps?(prog) ->
        run_list_of_inputs(prog, env)

      is_list(prog) ->
        run_list(prog, env)

      true ->
        raise "unknown run for #{inspect prog}"
    end
  end # === def run_prog

  def run_list_of_inputs list, env do
    Enum.reduce list, {nil, env}, fn(args, {_prev, env}) ->
      {args, env} = compile(args, env)
      env[env[:desc]].(args, env)
    end
  end # === def run_list_of_inputs

  @doc """
    Returns: { val, env }
  """
  def run_list(list, env) do
    [val, _func, env] = Enum.reduce list, [nil, nil, env], fn(token, [_prev, func, env]) ->
      cond do
        Map.has_key?(env, token) && !is_function(env[token])->
          [token, nil, env]

        Map.has_key?(env, token) && is_function(env[token])->
          [token, token, env]

        func -> # === run function
          {token, env} = compile(token, env)
          {token, env} = env[func].(token, env)
          [token, nil, env]

        true ->
          {token, env} = compile(token, env)
          [token, nil, env]
      end
    end
    {val, env}
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
            {is_key, val} = Enum.reduce String.split(name, "."), {true, env}, fn(key, {is_key, data}) ->
              if is_key && Map.has_key?(data, key) do
                {true, data[key]}
              else
                {nil, nil}
              end
            end

            if is_key do
              {val, env}
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

      true ->
        raise "Don't know what to do with: #{inspect x}"
    end # === cond
  end # === compile

end # === defmodule JSON_Spec


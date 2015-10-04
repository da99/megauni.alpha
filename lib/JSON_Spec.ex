

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

  #  Core funcs return an env.
  @core %{
    "const"      => :const,
    "before all" => :before_all,
    "after each" => :after_each,
    "desc"       => :desc,
    "it"         => :it,
    "input"      => :input,
    "output"     => :output
  }

  def const list, env do
    [ name | prog ] = list
    { stack , env } = JSON_Spec.run_prog(prog, env)
    Map.put env, name, List.last(stack)
  end

  def before_all prog, env do
    { _stack, env } = JSON_Spec.run_prog(prog, env)
    env
  end # === def run_before_all

  def after_each prog, env do
    if Map.has_key?(env, :after_each) do
      if is_list(env.after_each) do
        Map.put env, :after_each, List.append(env.after_each, prog)
      else
        Map.put env, :after_each, List.append([env.after_each], prog)
      end
    else
      Enum.into %{:after_each => env}, env
    end
  end # === def run_after_each

  def desc name, env do
    if !is_top?(env) do
      env = revert_env(env)
    end

    IO.puts "\n#{IO.ANSI.yellow}#{name}#{IO.ANSI.reset}"
    Enum.into %{ :desc=>name }, JSON_Spec.new_env(env)
  end

  def is_top? env do
    !env[:_parent_env]
  end

  def top_env env do
    if env[:_parent_env] do
      top_env(env[:_parent_env])
    else
      env
    end
  end

  def title raw, env do
    Regex.replace ~r/(\@[A-Z\_]+)(\s?([+\-\/\*])\s?([0-9]+))?/, raw, fn match, var, op_num, op, num ->
      if Map.has_key?(env, var) do
        if String.length(op_num) > 0 do
          to_string(apply(Kernel, String.to_atom(op), [env[var], String.to_integer(num)]))
        else
          to_string(env[var])
        end
      else
        match
      end
    end
  end

  def it raw_title, env do
    # env = desc_env
    # %{"it"=>it, "input"=>raw_input,"output"=>raw_output} = task
    # {actual, env}   = JSON_Spec.run_input(raw_input, env)
    # {expected, env} = JSON_Spec.run_output(raw_output, env)

    if !Map.has_key?(env, :it_count) do
      env = Map.put env, :it_count, 1
    end

    title = title(raw_title, env)

    env = new_env(env)

    num    = "#{JSON_Spec.format_num(env.it_count)})"
    bright = IO.ANSI.bright
    reset  = IO.ANSI.reset
    red    = "#{bright}#{IO.ANSI.red}"

    # if JSON_Spec.maps_match?(actual, expected) do
      IO.puts "#{bright}#{IO.ANSI.green}#{num}#{reset} #{title}"
    # else
      # IO.puts "#{bright}"
      # IO.puts "#{red}#{num}#{reset}#{bright} #{it}"
      # IO.puts "#{red}#{inspect actual} !== #{reset}#{bright}#{inspect expected}"
    # end
    # IO.puts reset
    # fin_env = Enum.into %{ :it_count => env.it_count + 1 }, desc_env

    # if Map.has_key?(fin_env, :after_each) do
      # {_stack, fin_env} = JSON_Spec.run(fin_env.after_each, fin_env)
    # end
    JSON_Spec.new_env(env)
  end # === def it

  def input input, env do
    cond do

      true ->
        IO.puts "INPUT:  #{inspect input}"
        env

      is_map(input) ->
        {input, env} = JSON_Spec.compile(input, env)
        env[env[:desc]].(input, env)

      is_list(input) && JSON_Spec.all_maps?(input) ->
        JSON_Spec.run_list_of_inputs(input, env)

      is_list(input) ->
        JSON_Spec.run_list(input, env)

      true -> raise "Don't know how to run: #{inspect input}"

    end # === cond
  end  # === run_input

  def output output, env do
    cond do
      true ->
        IO.puts "OUTPUT: #{inspect output}"
        env

      is_map(output) ->
        JSON_Spec.compile(output, env)

      is_list(output) && !JSON_Spec.all_maps?(output) ->
        JSON_Spec.run_list(output, env)

      true ->
        raise "Don't know what to do with input/output: #{inspect output}"
    end

    old = env
    env = JSON_Spec.revert_env(env)
    Map.put env, :it_count, old.it_count + 1
  end # === def run_output

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

  def new_env env do
    Map.put env, :_parent_env, env
  end

  def revert_env env do
    env[:_parent_env]
  end

  def run_file(path, custom_funcs) do
    json = File.read!(path) |> Poison.decode!

    IO.puts "\nfile: #{IO.ANSI.bright}#{path}#{IO.ANSI.reset}"

    env = Enum.into(%{:_parent_env=>nil}, custom_funcs)
    run_core json, env
  end # === run_file

  def run_core prog, env do
    if Enum.count(prog) == 0 do
      env
    else
      [ cmd | [arg | prog] ] = prog
      run_core prog, apply(JSON_Spec, @core[cmd], [arg, env])
    end
  end # === def run_core prog, env

  @doc """
    Returns: { stack, env }
  """
  def run_prog prog, env do
    cond do

      is_binary(prog) ->
        env[prog].( nil, env )

      is_list(prog) ->
        run_list(prog, env)

      true ->
        raise "unknown run for #{inspect prog}"
    end
  end # === def run_prog

  # def run_list_of_inputs list, env do
    # Enum.reduce list, {nil, env}, fn(args, {_prev, env}) ->
      # {args, env} = compile(args, env)
      # env[env[:desc]].(args, env)
    # end
  # end # === def run_list_of_inputs

  @doc """
    Returns: { stack, env }
  """
  def run_list(list, env) do

    [stack, prog, env] = Enum.reduce list, [[], [], env ], fn(token, [stack, prog, env]) ->
      if !Map.has_key?(env, token) do
        stack = stack ++ [token]
      else
        val = env[token]
        if is_function(val) do
          [stack, prog, env] = val.(stack, prog, env)
        else
          stack = stack ++ [val]
        end
      end # === if

      [stack, prog, env]
    end

    {stack, env}
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


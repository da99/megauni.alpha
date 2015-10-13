

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
  9) Raises error if list of input maps returns an error before last input.
  10) "key.key1.key2.key3" -> Returns string if key2 or earlier is not found
  """

  @reset   IO.ANSI.reset
  @bright  IO.ANSI.bright
  @green   IO.ANSI.green
  @yellow  "#{@bright}#{IO.ANSI.yellow}"
  @red     "#{@bright}#{IO.ANSI.red}"

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

  # Compiles elements from a list of args (prog)
  def take list, num, env do
    if Enum.count(list) < num do
      raise "Out of bounds: #{inspect num} #{inspect list}"
    end

    args = Enum.take list, num

    {args, env} = Enum.reduce args, {[], env}, fn raw_arg, {args, env} ->
      {fin_arg, env} = compile(raw_arg, env)
      {(args ++ [fin_arg]), env}
    end

    list = Enum.take list, (num - Enum.count(list))
    if num == 1 do
      [List.first(args), list, env]
    else
      [args, list, env]
    end
  end # === def args

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

    IO.puts "\n#{@yellow}#{name}#{@reset}"
    Enum.into %{ :desc=>name }, new_env(env)
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

  def it raw_title, prev_env do
    env = new_env(prev_env)
    env = if Map.has_key?(env, :it_count) do
      Map.put env, :it_count, env.it_count + 1
    else
      Map.put env, :it_count, 1
    end

    title = title(raw_title, env)
    num   = "#{format_num(env.it_count)})"

    Enum.into %{:it=>title, :it_count=>num}, new_env(env)
  end # === def it

  def input input, env do
    cond do
      is_map(input) ->
        {input, env} = compile(input, env)
        [stack, _prog, env] = env[env[:desc]].([], [input], env)
        Map.put env, :actual, List.last(stack)

      list_of_maps?(input) ->
        with_index = Enum.with_index(input)
        {_, last}  = List.last(with_index)
        Enum.reduce with_index, env, fn({map, i}, env) ->
          env = input map, env
          if i < last && is_map(env.actual) && Map.has_key?(env.actual, "error") do
            raise env.actual["error"]
          end
          env
        end

      is_list(input) ->
        [stack, _prog, env] = run_list(input, env)
        Map.put env, :actual, List.last(stack)

      true ->
        raise "Don't know how to run: #{inspect input}"
    end # === cond
  end  # === run_input

  def output output, env do
    {expected, env} = cond do
      is_map(output) ->
        compile(output, env)

      is_list(output) && !list_of_maps?(output) ->
        run_list(output, env)

      true ->
        raise "Don't know what to do with input/output: #{inspect output}"
    end

    if maps_match?(expected, env.actual) do
      IO.puts "#{@bright}#{@green}#{env.it_count}#{@reset} #{env.it}"
    else
      IO.puts "#{@bright}#{@red}#{env.it_count}#{@reset}#{@bright} #{env.it}"
      IO.puts "#{@bright}#{inspect expected} !== #{@reset}#{@red}#{@bright}#{inspect env.actual}"
      IO.puts @reset
      Process.exit(self, "spec failed")
    end
    IO.puts @reset

    if Map.has_key?(env, :after_each) do
      {_stack, env} = run_list(env.after_each, env)
    end
    carry_over(env, :it_count)
  end # === def run_output

  def canon_key(x) do
    x |> String.strip
      |> (&(Regex.replace(~r/\s+/, &1," "))).()
  end

  def format_num(num) do
    space = String.duplicate " ", 2 - String.length(to_string(num))
    "#{space}#{num}"
  end

  def list_of_maps? list do
    if !is_list(list) do
      false
    else
      !Enum.find list, fn(v) ->
        !is_map(v)
      end
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

  def carry_over env, key_or_list do
    if is_list(key_or_list) do
      Enum.reduce key_or_list, env, fn (key, env) ->
        carry_over env, key
      end
    else
      key = key_or_list
      Map.put revert_env(env), key, env[key]
    end
  end

  def revert_env env do
    if Map.has_key?(env, :_parent_env) && env._parent_env do
      env._parent_env
    else
      raise "No parent env found."
    end
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

  @doc """
    Returns: { stack, env }
  """
  def run_list(list, env) do

    [stack, prog, env] = Enum.reduce list, [[], [], env ], fn(token, [stack, prog, env]) ->
      if !Map.has_key?(env, token) || !is_function(env[token]) do
        stack = stack ++ [token]
        [stack, prog, env]
      else
        [stack, prog, env] = env[token].(stack, prog, env)
      end # === if
    end

    {stack, env}
  end

  @doc """
    Examples:
    iex> .compile("user.id", env)
    iex> .compile("screen_name", env)
    iex> .compile(%{"screen_name": "screen_name"}, env)
    iex> .compile([%{}, %{}], env)
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


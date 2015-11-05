

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

  @doc """
    Compiles elements from a list of args (ie prog)
    Returns:
      { compiled_value, list, env }
  """
  def take list, num, env do
    if Enum.count(list) < num do
      raise "Out of bounds: #{inspect num} #{inspect list}"
    end

    raw_args = Enum.take list, num

    {args, env} = Enum.reduce raw_args, {[], env}, fn raw_arg, {args, env} ->
      {fin_arg, env} = compile(raw_arg, env)
      {(args ++ [fin_arg]), env}
    end

    list = Enum.take list, (num - Enum.count(list))
    if num == 1 do
      {List.first(args), list, env}
    else
      {args, list, env}
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
      if !is_list(prog) do
        prog = [prog]
      end
      Enum.into %{:after_each => prog}, env
    end
  end # === def run_after_each

  def desc name, env do
    if !is_top?(env) do
      env = revert_env(env)
    end

    IO.puts "#{@yellow}#{name}#{@reset}"
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

  def it raw_title, prev_env do
    env = new_env(prev_env)
    env = if Map.has_key?(env, :it_count) do
      Map.put env, :it_count, env.it_count + 1
    else
      Map.put env, :it_count, 1
    end

    {compiled_it, env} = compile(raw_title, env)

    Enum.into %{
      :it       => compiled_it,
      :it_count => env.it_count
    }, new_env(env)
  end # === def it

  def is_error? e do
    is_map(e) &&
    (
      Map.has_key?(e, "error") ||
      Map.has_key?(e, "user_error") ||
      Map.has_key?(e, "user error") ||
      Map.has_key?(e, "programmer_error") ||
      Map.has_key?(e, "programmer error")
    )
  end

  def input raw, env do
    cond do
      is_map(raw) ->
        input([raw], env)

      is_list_of_maps?(raw) ->
        if Enum.count(raw) > 1 do
          env = Map.put env, :raise_errors, true
        end
        new_list = Enum.reduce raw, [], fn(map, list) ->
          list ++ [ env[:desc], map ]
        end
        input(new_list, env)

      is_list(raw) ->
        env = Map.put env, :raise_errors, true
        {stack, env} = run_list(raw, env)
        Map.put env, :actual, List.last(stack)

      true ->
        raise "Don't know how to run: #{inspect raw}"
    end # === cond
  end  # === run_input

  def output output, env do
    {expected, env} = cond do
      is_map(output) ->
        compile(output, env)

      is_list_of_maps?(output) ->
        Enum.reduce output, {[], env}, fn(m, {list, env}) ->
          {new_map, env} = compile(m, env)
          {list ++ [new_map], env}
        end

      is_list(output) ->
        {stack, env} = run_list(output, env)
        {List.last(stack), env}

      true ->
        raise "Don't know what to do with input/output: #{inspect output}"
    end

    num = "#{format_num(env.it_count)})"
    if maps_match?(env.actual, expected) do
      IO.puts "#{@bright}#{@green}#{num}#{@reset} #{env.it}#{@reset}"
    else
      IO.puts "#{@bright}#{@red}#{num}#{@reset}#{@bright} #{env.it}"
      IO.puts "#{@bright}#{inspect expected} !== #{@reset}#{@red}#{@bright}#{inspect env.actual}"
      IO.puts @reset
      Process.exit(self, "spec failed")
    end

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

  def is_list_of_maps? list do
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
    cond do
      is_map(actual) && is_map(expected) ->
        !Enum.find expected, fn({k,v}) ->
          cond do
            (is_integer(actual[k]) && v == "INT") ->
              false
            true ->
              !(actual[k] == v)
          end
        end
      true ->
        actual === expected
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

    IO.puts "\nfile: #{@bright}#{path}#{@reset}"

    env = Enum.into(%{:_parent_env=>nil}, custom_funcs)
    run_core json, env
    IO.puts "#{@bright}#{@green}All tests pass.#{@reset}"
  end # === run_file

  def run_core prog, env do
    cond do
      Enum.count(prog) == 0 ->
        env

      is_binary(List.first prog) ->
        [ cmd | [arg | prog] ] = prog
        run_core prog, apply(JSON_Spec, @core[cmd], [arg, env])

      is_map(List.first prog) ->
        [ %{"it"=>it_, "input"=>input_, "output"=>output_} | prog ] = prog
        prog = ["it", it_, "input", input_, "output", output_ | prog]
        run_core(prog, env)
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
    run_list([], list, env)
  end

  @doc """
    Mostly used by core funcs such as :input, :output,
    and the main JSON specs.

    Returns: { stack, env }
  """
  def run_list stack, prog, env do
    cond do
      Enum.count(prog) == 0 ->
        {stack, env}

      is_number(List.first(prog)) ->
        [num | prog] = prog
        run_list (stack ++ [num]), prog, env

      true ->
        [token | prog] = prog

        if !is_function(env[token]) do
          raise "Function not found: #{inspect token}"
        end
        {stack, prog, env} = env[token].(stack, prog, env)

        # === If last value is an error and there is still more
        #     to process in the prog, raise the error:
        if env[:raise_errors] && Enum.count(prog) != 0 && is_error?(List.last(stack)) do
          raise "From: #{inspect token} Result: #{inspect(List.last(stack))}"
        end

        stack = case List.last(stack) do
          {:JSON_Spec, :ignore_last_error} -> Enum.take(stack, Enum.count(stack) - 1)
          _ -> stack
        end

        run_list stack, prog, env
    end # == cond
  end # === def run_list

  @doc """
    Used when you want to "compile" args to be used
    in a custom function:
       JSON: "input": [ "create something", { "some_id": "sn.id" } ]
    In this case, the arg for "create something" will be compiled.
    NOTE: The value of "input" would be run through :run_list.

    Usage in Elixir:
    iex> .compile("user.id", env)
    iex> .compile("screen_name", env)
    iex> .compile(%{"screen_name": "screen_name"}, env)
    iex> .compile([%{}, %{}], env)

    Returns: {result, env}
  """
  def compile(x, env) do

    cond do

      is_map(x) -> # === used to compile inputs and outputs
        result = Enum.reduce x, %{:map=>%{}, :env=>env}, fn({k,v}, pair) ->
          {new_v, new_e} = compile(v, env)
          Enum.into(
            %{:map=>Map.put(pair.map, k, new_v), :env=>new_e},
            pair
          )
        end
        {result.map, result.env}

      is_number(x) ->
        {x, env}

      is_binary(x) ->
        raw = x
        x = Regex.replace ~r/(\@[A-Z\_]+)(\s?([+\-\/\*])\s?([0-9]+))?/, raw, fn match, var, op_num, op, num ->
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

        name = canon_key(x)
        cond do
          # === is it a simple k/v lookup?
          Map.has_key?(env, name) && !is_function(env[name]) ->
            {env[name], env}

          # === is function a "compile" func/1 or a run_prog func/3?
          Map.has_key?(env, name) && is_function(env[name], 1)  ->
            {val, env} = env[name].(env)

          true -> # === Check for "key.key.key"
            {is_key, val} = Enum.reduce String.split(name, "."), {true, env}, fn(key, {is_key, data}) ->

              if is_key && Map.has_key?(data, key) do
                {true, data[key]}
              else
                {nil, nil}
              end
            end

            cond do
              is_key           -> {val, env}
              env["lookup kv"] -> env["lookup kv"].(x, env)
              true             -> {x, env}
            end
        end # === cond

      is_list(x) ->
        Enum.reduce x, {[], env}, fn(var, {arr, env}) ->
          {result, env} = compile(var, env)
          { arr ++ [result], env}
        end

      is_nil(x) ->
        {nil, env}

      true ->
        raise "Don't know what to do with: #{inspect x}"
    end # === cond
  end # === compile

end # === defmodule JSON_Spec


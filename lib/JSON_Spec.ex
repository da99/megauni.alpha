

defmodule JSON_Spec do

  @reset   IO.ANSI.reset
  @bright  IO.ANSI.bright
  @green   IO.ANSI.green
  @yellow  "#{@bright}#{IO.ANSI.yellow}"
  @red     "#{@bright}#{IO.ANSI.red}"

  defmodule Core do

    def get stack, prog, env do
      {[name], prog, env} = JSON_Spec.take(prog, 1, env)
      val = stack |> List.last |> Map.fetch!(name)
      {stack ++ [val], prog, env}
    end

    def const list, env do
      [ name | prog ] = list
      { stack, prog , env } = JSON_Spec.run([], prog, env)
      Map.put env, name, List.last(stack)
    end

    def before_all prog, env do
      { _stack, _prog, env } = JSON_Spec.run([], prog, env)
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

    def input raw, env do
      cond do
        is_map(raw) ->
          input([raw], env)

        is_list_of_maps?(raw) ->
          new_list = Enum.reduce raw, [], fn(map, list) ->
            list ++ [ env[:desc], map ]
          end
          input(new_list, env)

        is_list(raw) ->
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

  end # === defmodule Core ========================================

  def take([list | prog], num, env) when is_list(list) do
    {args, _empty, env} = run([], list, env)
    if Enum.count(args) < num do
      raise "Not enought args: #{inspect num} desired from: #{inspect list}"
    end

    fin = Enum.take(args, num)
    {args, env}
  end

  @doc """
    Compiles elements from a list of args (ie prog)
    Returns:
      { compiled_value, list, env }
  """
  def take list, num, env do
    if Enum.count(list) < num do
      raise "Out of bounds: #{inspect num} #{inspect list}"
    end

    {args, _empty, env} = run([], Enum.take(list, num), env}
    {args, env}
  end # === def args

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

  def modules_to_map arr do
    arr
    |> Enum.map( &(module_to_map &1) )
    |> Enum.reduce(%{}, &(Map.merge &2, &1))
  end

  def module_to_map mod do
    Enum.reduce mod.__info__(:functions), %{}, fn({name, arity}, map) ->
      Map.put(map, name, fn(stack, prog, env) ->
        apply(mod, name, [stack, prog, env])
      end)
    end
  end

  def run_files files, env \\ nil do
    Enum.each files, fn(file) ->
      JSON_Spec.run_file(file, env)
    end
  end # == def run_files

  def run_file(path, raw_env \\ nil) do
    env = case raw_env do
      none when is_nil(none) -> %{}
      arr  when is_list(arr) -> modules_to_map(arr)
      mod                    -> module_to_map(mod)
    end

    look_in = (Map.get env, "look_in", []) ++ [JSON_Spec.Core]
    env     = Map.put env, "look_in", look_in
    json    = File.read!(path) |> Poison.decode!

    IO.puts "\nfile: #{@bright}#{path}#{@reset}"

    env = Enum.into(%{:_parent_env=>nil}, env)
    run [], json, env
    IO.puts "#{@bright}#{@green}All tests pass.#{@reset}"
  end # === run_file

  def get(raw, env) do
    atom = to_atom(raw)
    cond do
      Map.has_key?(env, raw)  -> env[raw]
      Map.has_key?(env, atom) -> env[atom]
      true                    -> raw
    end # cond
  end # def

  def to_prog(string) when is_binary(string) do
    result = Regexp.run ~r/^([a-zA-Z0-9\_]+)\[([^\]]?)\]\.?(.+)?$/, string
    if !result do
      nil
    else
      [_match, func, raw_args |  tail ] = result
      gets = Enum.reduce tail, [], fn(str, arr) ->
        fields = String.split str, ","
        Enum.reduce fields, arr, fn(fld, arr) ->
          arr ++ ["get", [fld]]
        end
      end
      [func, raw_args] ++ gets
    end
  end

  @doc """
    "some string with @var" -> "some string with var value"
  """
  def replace_vars(x, env) when is_binary(x) do
    raw = x
    x = Regex.replace ~r/(\@[A-Z\_]+)(\s?([+\-\/\*])\s?([0-9]+))?/, raw, fn(match, var, op_num, op, num) ->
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
  end # === def replace_vars

  def run stack, [], env do
    {stack, [], env}
  end

  def run(stack, [num | prog], env) when is_number(num) do
    run(stack ++ [num], prog, env)
  end

  def run(stack, [map | prog], env) when is_map(map) do
    {map, env} = Enum.reduce map, {%{}, env}, fn({k,v}, {fin, env}) ->
      {stack, _prog, env} = run([], [v], env}
      {Map.put(fin, k, List.last(stack)), env}
    end

    run(stack ++ [map], prog, env)
  end

  def run(stack, [raw_string | prog], env) when is_binary(raw_string) do
    compiled = raw_string |> replace_vars(env) |> get(env)

    {stack, prog, env} = case compiled do

      func when is_function(func) ->
        func.( stack, prog, env )

      string when is_binary(string) ->
        new_prog = to_prog string

        if new_prog do
          {new_stack, _prog, env} = run(stack, new_prog, env)
          {stack ++ new_stack, prog, env}
        else
          {stack ++ [string], prog, env}
        end

    end # case ==========================

    if Enum.count(prog) != 0 do

      # === If last value is an error and there is still more
      #     to process in the prog, raise the error:
      last = List.last(stack)
      if is_error?(last) do
        raise "From: #{inspect string} Result: #{inspect last}"
      end

    end # == if prog count != 0

    run stack, prog, env
  end # === def run stack, prog, env

end # === defmodule JSON_Spec


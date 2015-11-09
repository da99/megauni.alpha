

defmodule JSON_Spec do

  @reset   IO.ANSI.reset
  @bright  IO.ANSI.bright
  @green   IO.ANSI.green
  @yellow  "#{@bright}#{IO.ANSI.yellow}"
  @red     "#{@bright}#{IO.ANSI.red}"

  def spec_funcs do
    aliases = %{
      "==="        => :exactly_like,
      "~="         => :similar_to
    }
    Map.merge spec_func_map(JSON_Spec), aliases
  end

  def spec_func_map mod do
    Enum.reduce mod.__info__(:functions), %{}, fn({name, arity}, map) ->
      if arity == 3 do
        map = Map.put map, Atom.to_string(name), name
      end
      map
    end
  end

  def get stack, prog, env do
    {[name], prog, env} = JSON_Spec.take(prog, 1, env)
    val = stack |> List.last |> Map.fetch!(name)
    {stack ++ [val], prog, env}
  end

  def __ stack, prog, env do
    run(stack, [env[:desc] | prog], env)
  end

  @doc """
    This function runs the "prog" without calling funcs in the
    form of:  "string", [].  Functions in the form of "func[].id"
    still run. Example:
      ["data", ["error", ["user_error", "name[].name"]]]
      =>
      ["error", ["user_error", "some name"]]
  """
  def data stack, prog, env do
    [ data_prog | prog ] = prog

    {data, env} = Enum.reduce data_prog, {[], env}, fn(v, {data, env}) ->
      case v do
        list when is_list(list) ->
          {new_stack, _empty, env} = data([], [list], env)
          {data ++ new_stack, env}
        _ ->
          {new_stack, _empty, env} = run([], [v], env)
          { data ++ [List.last(new_stack)], env}
      end
    end
    {stack ++ [data], prog, env}
  end # === def data

  def const list, env do
    [ name | prog ] = list
    { stack, prog , env } = JSON_Spec.run([], prog, env)
    Map.put env, name, List.last(stack)
  end

  def before_all prog, env do
    { _stack, _prog, env } = JSON_Spec.run([], prog, env)
    env[:desc]
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

  def desc stack, prog, env do
    if !JSON_Spec.is_top?(env) do
      env = JSON_Spec.revert_env(env)
    end

    {[name], prog, env} = take(prog, 1, env)
    IO.puts "#{@yellow}#{name}#{@reset}"
    env = Enum.into %{ :desc=>name }, JSON_Spec.new_env(env)
    {stack, prog, env}
  end

  def it stack, prog, env do
    {[title], prog, env} = take(prog, 1, env)

    env = new_env(env)
    env = if Map.has_key?(env, :it_count) do
      Map.put env, :it_count, env.it_count + 1
    else
      Map.put env, :it_count, 1
    end

    env = Map.put(env, :it, title)
    num = "#{format_num(env.it_count)})"
    IO.puts "#{@bright}#{num}#{@reset} #{env.it}#{@reset}"

    {stack, prog, env}
  end # === def it

  def input stack, prog, env do
    [ input_prog | prog ] = prog
    {results, _empty, env} = run([], input_prog, env)
    actual = results |> List.last
    env = Map.put(env, :actual, actual)
    {stack ++ [actual], prog, env}
  end  # === run_input

  def exactly_like stack, prog, env do
    actual = List.last stack
    [new_prog | prog] = prog
    {raw_target, _empty, env} = run([], new_prog, env)
    expected = raw_target |> List.last

    if actual == expected do
      {stack ++ ["the same", :spec_fulfilled], prog, env}
    else
      IO.puts "\n#{@bright}#{inspect actual} needs to == #{@reset}#{@red}#{@bright}#{inspect expected}#{@reset}"
      Process.exit(self, "spec failed")
    end
  end

  def similar_to stack, prog, env do
    actual = List.last stack
    [raw | prog] = prog
    {args, _empty, env} = run([], raw, env)
    expected = List.last args
    similar_to!(actual, expected)
    env = Map.put env, :spec_count, get(:spec_count, env) + 1
    {stack ++ [:spec_fulfilled], prog, env}
  end

  def similar_to!(actual, expected) when is_map(actual) and is_map(expected) do
    key = Enum.find Map.keys(expected), fn(k) ->
      cond do
        (is_integer(actual[k]) && expected[k] == "INT") ->
          false
        true ->
          !(actual[k] == expected[k])
      end
    end
    if key do
      IO.puts "#{@bright}Key mismatch: #{key} : #{inspect actual[key]} != #{@red}#{inspect expected[key]}#{@reset}"
      IO.puts "#{@bright}#{inspect actual}"
      IO.puts "#{@reset}#{@red}#{@bright}#{inspect expected}"
      IO.puts @reset
      raise "spec failed"
    else
      true
    end
  end

  def similar_to!(actual, expected) when is_list(actual) and is_list(expected) do
    if Enum.count(actual) != Enum.count(expected) do
      similar_to_fail actual, expected
    end

    Enum.find Enum.with_index(expected), fn({val, i}) ->
      ! similar_to!( Enum.at(actual,i), Enum.at(expected, i))
    end
  end

  def similar_to!(actual, expected) when is_binary(actual) and is_binary(expected) do
    if actual != expected do
      similar_to_fail actual, expected
    end
    true
  end

  def similar_to!(actual, expected) when is_binary(actual) and is_map(expected) do
    if !(actual =~ expected) do
      similar_to_fail actual, expected
    end
    true
  end

  def similar_to_fail actual, expected do
    IO.puts "\n#{@bright}#{inspect actual} needs to be similar to #{@reset}#{@red}#{@bright}#{inspect expected}"
    IO.puts @reset
    raise "spec failed"
  end

  def similar_to! actual, expected do
    if actual == expected do
      true
    else
      IO.puts "\n#{@bright}#{inspect actual} needs to be similar to #{@reset}#{@red}#{@bright}#{inspect expected}"
      IO.puts @reset
      Process.exit(self, "spec failed")
    end
  end

  def raw stack, prog, env do
    [args | prog] = prog
    {stack ++ args, prog, env}
  end

  def passed env do
    # num = "#{format_num(get(:it_count, env))})"
    # IO.puts "#{@bright}#{@green}#{num}#{@reset} #{get(:it, env)}#{@reset}"
  end # === def failed

  def failed actual, expected, env do
    IO.print "\r"
    num = "#{JSON_Spec.format_num(env.it_count)})"
    IO.puts "#{@bright}#{@red}#{num}#{@reset}#{@bright} #{env.it}"
    IO.puts "#{@bright}#{inspect expected} !== #{@reset}#{@red}#{@bright}#{inspect env.actual}"
    IO.puts @reset
    Process.exit(self, "spec failed")
  end # === def failed

  def output stack, prog, env do
    actual = stack |> List.last
    [output_prog | prog] = prog

    {results, _empty, env} = run([actual], output_prog, env)
    spec_done = results |> List.last

    stack = stack ++ [spec_done]

    if spec_done != :spec_fulfilled do
      Process.exit(self, "\nNo spec found.")
    end

    if Map.has_key?(env, :after_each) do
      {_stack, _empty, env} = JSON_Spec.run(stack, env.after_each, env)
    end

    env = JSON_Spec.carry_over(env, [:it, :it_count, :spec_count])
    passed env
    {stack, prog, env}
  end # === def output

  @doc """
    Compiles elements from a list of args (ie prog)
    Returns:
      { compiled_list_of_args, prog, env }
  """
  def take([list | prog], num, env) when is_list(list) do
    {args, _empty, env} = run([], list, env)
    if Enum.count(args) < num do
      raise "Not enought args: #{inspect num} desired from: #{inspect list}"
    end

    {Enum.take(args, num), prog, env}
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

  def to_atom x do
    if is_atom(x) do
    x
    else
      x
      |> String.downcase
      |> String.strip
      |> String.to_atom
    end
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
    name_counter = String.to_atom "#{name}_counter"

    counter = (get(name_counter, env) || 0) + 1
    name_id = String.to_atom "#{name}_#{counter}"

    env
    |> Map.put(name_counter, counter)
    |> Map.put(name_id, val)
    |> Map.put(name, val)
  end

  def new_env env do
    Map.put env, :_parent_env, env
  end

  def carry_over(child, list ) when is_list(list) do
    Enum.reduce list, revert_env(child), fn (key, parent) ->
      Map.put parent, key, get(key, child)
    end
  end

  def carry_over(env, key) when is_atom(key) do
    Map.put revert_env(env), key, get(key, env)
  end

  def revert_env env do
    if Map.has_key?(env, :_parent_env) && env._parent_env do
      env._parent_env
    else
      raise "No parent env found."
    end
  end

  def to_map(arr) when is_list(arr) do
    Enum.reduce arr, %{}, fn(mod, map) ->
      Map.merge map, to_map(mod)
    end
  end

  def to_map(mod) do
    funcs = mod.__info__(:functions)
    if funcs[:spec_funcs] == 0 do
      Enum.reduce mod.spec_funcs, %{}, fn({alias_name, name}, map) ->
        Map.put(map, alias_name, fn(stack, prog, env) ->
          apply(mod, name, [stack, prog, env])
        end)
      end
    else
      Enum.reduce funcs, %{}, fn({name, arity}, map) ->
        if arity == 3 do
          map = Map.put(map, Atom.to_string(name), fn(stack, prog, env) ->
            apply(mod, name, [stack, prog, env])
          end)
        end
        map
      end
    end
  end # === def

  def run_files files, env \\ nil do
    Enum.each files, fn(file) ->
      JSON_Spec.run_file(file, env)
    end
  end # == def run_files

  def run_file(path, raw_env \\ %{}) do
    # === Defaults for env
    env = Enum.into(
      %{ :spec_count  => 0, :it_count    => 0 },
      Map.merge(to_map(JSON_Spec), to_map(raw_env))
    )

    {_stack, _prog, env} = run(
      [], (File.read!(path) |> Poison.decode!), env
    )

    IO.puts "\nfile: #{@bright}#{path}#{@reset}"
    if env.spec_count > 0 do
      IO.puts "#{@bright}#{@green}All tests pass.#{@reset}"
    else
      IO.puts "#{@bright}#{@red}No tests found.#{@reset}"
    end
  end # === run_file

  def to_json_to_elixir val do
    case val do
      {:ok, val} ->
        [:ok, val] |> to_json_to_elixir
      {atom_1, {atom_2, v}} when is_atom(atom_1) and is_atom(atom_2) ->
        [atom_1, [atom_2, v]] |> to_json_to_elixir
      _ ->
        val |> Poison.encode! |> Poison.decode!
    end
  end # === def to_json_to_elixir

  def get(name, env) do
    func = cond do
      Map.has_key?(env, name) -> env[name]
      is_top?(env)            -> nil
      true                    -> get(name, top_env(env))
    end # cond

    if !func && is_binary(name) && name =~ ~r/\./ do
      func = name
      |> String.downcase
      |> String.replace(".", "_")
      |> get(env)
    end

    func
  end # def

  def to_args(string) when is_binary(string) do
    string = string |> String.strip
    case string do
      "" -> []
      _  -> string |> String.split(",") |> Enum.map(&(String.strip &1))
    end
  end

  def to_prog(string) when is_binary(string) do
    result = Regex.run ~r/^([a-zA-Z0-9\_]+)\[([^\]]*)\]\.?(.+)?$/, string
    if !result do
      nil
    else
      [_match, func, raw_args |  tail ] = result

      args = raw_args |> to_args

      gets = Enum.reduce tail, [], fn(str, arr) ->
        fields = String.split str, "."
        Enum.reduce fields, arr, fn(fld, arr) ->
          arr ++ ["get", [fld]]
        end
      end

      [func, args] ++ gets
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

  def run(stack, [arr | prog], env) when is_list(arr) do
    {new_arr, _empty, env} = run([], arr, env)
    run(stack ++ [new_arr], prog, env)
  end

  def run(stack, [string, arr_or_map | prog], env) when (is_binary(string) and (is_list(arr_or_map) or is_map(arr_or_map))) do
    func = get(string, env)

    {stack, prog, env} = if func do
      func.( stack, [arr_or_map | prog], env )
    else
      raise "Function not found: #{inspect string}"
      {stack ++ [string], [ arr_or_map | prog ], env}
    end

    run stack, prog, env
  end

  def run(stack, map, env) when is_map(map) do
    run stack, [map], env
  end

  def run(stack, [map | prog], env) when is_map(map) do
    {map, env} = Enum.reduce map, {%{}, env}, fn({k,v}, {fin, env}) ->
      {stack, _prog, env} = run([], [v], env)
      {Map.put(fin, k, List.last(stack)), env}
    end

    run(stack ++ [map], prog, env)
  end

  def run(stack, [raw_string | prog], env) when is_binary(raw_string) do
    string   = raw_string |> replace_vars(env)
    new_prog = to_prog(string) # === e.g.: func[..].field.field.field

    {stack, prog, env} = if new_prog do
      {new_stack, _empty, env} = run(stack, new_prog, env)
      {stack ++ new_stack, prog, env}
    else
      {stack ++ [string], prog, env}
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


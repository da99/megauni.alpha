
defmodule JSON_Applet do

  def canon_key(x) do
    x |> String.strip
      |> (&(Regex.replace(~r/\s+/, &1," "))).()
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

  def to_map(map) when is_map(map) do
    map
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

    last = List.last(stack)
    case last do
      {:error, _} ->
        raise "From: #{inspect string} Result: #{inspect last}"
      _ ->
        run stack, prog, env
    end
  end # === def run stack, prog, env

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

    canon_key(x)
  end # === def replace_vars

end # === defmodule JSON_Applet

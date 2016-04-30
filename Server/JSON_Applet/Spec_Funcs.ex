
defmodule JSON_Applet.Spec_Funcs do

  import DA_3001, only: :functions
  import JSON_Applet, only: :functions

  def spec_funcs do
    aliases = %{
      "==="        => :exactly_like,
      "~="         => :similar_to
    }
    Map.merge func_map(JSON_Applet.Spec_Funcs), aliases
  end

  def const stack, [ raw | prog ], env do
    { [[name , val]], _empty , env } = JSON_Applet.run([], ["data", raw], env)
    env = JSON_Applet.put env, name, val
    {stack ++ [val], prog, env}
  end

  def ok_val stack, [[]|prog], env do
    val = case List.last(stack) do
      {:ok, val} -> val
      ["ok", val] -> val
    end
    {stack ++ [val], prog, env}
  end

  def pop(stack, [raw|prog], env) when is_list(raw) do
    {f,s,e} = result = JSON_Applet.run([], raw, env)

    stack |> In.spect
    Process.exit self, "=== stopped"

    {[args], _empty, env} = result
    {stack ++ [List.last args], prog, env}
  end

  def before_all prog, env do
    { _stack, _prog, env } = JSON_Applet.run([], prog, env)
    env[:desc]
  end # === def run_before_all

  def after_each stack, [ args | prog ], env do
    # Get :after_each for the current env
    after_each = get(:after_each, env) || []
    env = Map.put env, :after_each, (after_each ++ args)
    {stack, prog, env}
  end # === def run_after_each

  def get(stack, [ raw | prog ], env) when is_list(raw) do
    {[[name]], prog, env} = JSON_Applet.run([], ["data", raw], env)
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

  def desc stack, prog, env do
    if !is_top?(env) do
      env = JSON_Applet.revert_env(env)
    end

    {[name], prog, env} = take(prog, 1, env)
    IO.puts color([:yellow, name, :reset])
    env = Enum.into %{ :desc=>name }, new_env(env)
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
    num = :it_count |> get(env) |> JSON_Applet.Spec.format_num
    IO.puts color([:bright, :yellow, num, ") ", :reset, get(:it, env), :reset])

    {stack, prog, env}
  end # === def it

  def input stack, prog, env do
    [ input_prog | prog ] = prog
    {results, _empty, env} = run([], input_prog, env)
    actual = results |> List.last
    env = Map.put(env, :actual, actual)
    {stack ++ [actual], prog, env}
  end  # === run_input

  def exactly_like stack, [new_prog|prog], env do
    actual = List.last stack
    {raw_target, _empty, env} = run([], new_prog, env)
    expected = raw_target |> List.last

    if actual == expected do
      {stack, prog, JSON_Applet.Spec.inc_spec_count(env)}
    else
      IO.puts color(["\n", :bright, inspect(actual), " needs to == ", :reset, :red, :bright, inspect(expected), :reset])
      Process.exit(self, "spec failed")
    end
  end

  def output stack, prog, env do
    actual = stack |> List.last
    [output_prog | prog] = prog

    spec_count = JSON_Applet.get!(:spec_count, env)
    {results, _empty, env} = run([actual], output_prog, env)

    if spec_count == JSON_Applet.get!(:spec_count, env) do
      IO.puts ""
      Process.exit(self, "No spec found.")
    end

    # == Run :after_each
    {_stack, _empty, env} = JSON_Applet.run(stack, get(:after_each, env) || [], env)

    env = JSON_Applet.carry_over(env, [:it, :it_count, :spec_count])
    {stack, prog, env}
  end # === def output

  def similar_to stack, prog, env do
    actual = List.last stack
    [raw | prog] = prog
    {args, _empty, env} = run([], raw, env)
    expected = List.last args
    msg = "\nactual:   #{inspect actual}\nexpected: #{inspect expected}"
    JSON_Applet.Spec.similar_to!(actual, expected, msg)
    {stack, prog, JSON_Applet.Spec.inc_spec_count(env)}
  end

  def raw stack, prog, env do
    [args | prog] = prog
    {stack ++ args, prog, env}
  end

end # === defmodule JSON_Applet.Spec_Funcs

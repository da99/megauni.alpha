
defmodule JSON_Applet.Spec_Funcs do

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
    num = "#{:it_count |> get(env) |> format_num})"
    IO.puts "#{@bright}#{num}#{@reset} #{get(:it, env)}#{@reset}"

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

  def similar_to stack, prog, env do
    actual = List.last stack
    [raw | prog] = prog
    {args, _empty, env} = run([], raw, env)
    expected = List.last args
    similar_to!(actual, expected)
    env = Map.put env, :spec_count, get(:spec_count, env) + 1
    {stack ++ [:spec_fulfilled], prog, env}
  end

  def raw stack, prog, env do
    [args | prog] = prog
    {stack ++ args, prog, env}
  end

end # === defmodule JSON_Applet.Spec_Funcs

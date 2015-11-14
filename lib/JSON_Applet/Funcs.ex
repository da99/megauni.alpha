
defmodule JSON_Applet.Funcs do

  def repeat(stack, prog, env) do
    {[num | list], prog, env} = JSON_Applet.take(prog, 1, env)
    {env, new_stack} = Enum.reduce 0..num, {env, []}, fn(_i, {env, _stack}) ->
      {stack, _empty, env} = JSON_Applet.run([], list, env)
      {stack ++ [List.last(stack)], [], env}
    end

    {stack ++ new_stack, prog, env}
  end

  def comment(stack, [args | prog], env) do
    {stack, prog, env}
  end

  def array(stack, prog, env) do
    { arr, prog, env } = JSON_Applet.take(prog, 1, env)
    {stack ++ [arr], prog, env}
  end

  def length(stack, prog, env) do
    {stack ++ [stack |> List.last |> Enum.count], prog, env}
  end

  def pluck(stack, prog, env) do
    {[key], prog, env} = JSON_Applet.take(prog, 1, env)
    results = Enum.map List.last(stack), fn(x) ->
      x[key]
    end
    {stack ++ [results], prog, env}
  end

  def unique(stack, prog, env) do
    arr = List.last(stack)
    { stack ++ [Enum.uniq(arr)], prog, env }
  end

end # === defmodule JSON_Applet.Funcs

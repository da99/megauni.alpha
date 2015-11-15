
defmodule JSON_Applet.Funcs do

  def repeat(stack, [ [raw_num | sub_prog] | prog], env) do
    {[[num]], _empty, env} = JSON_Applet.run([], ["data", [raw_num]], env)

    {new_stack, env} = Enum.reduce 1..num, {[], env}, fn(_i, {sub_stack, env}) ->
      {results, _empty, env} = JSON_Applet.run([], sub_prog, env)
      {sub_stack ++ [List.last(results)], env}
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

  def length(stack, [[]|prog], env) do
    num = stack |> List.last |> Enum.count
    {stack ++ [ num ], prog, env}
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

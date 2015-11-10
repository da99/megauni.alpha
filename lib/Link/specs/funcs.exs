
defmodule Link.Spec_Funcs do

  def create_link(stack, prog, env) do
    {args, prog, env} = JSON_Spec.take(prog, 1, env)

    if (args |> List.first |> is_number) do
      [user_id | args] = args
    else
      user_id = (
        env["user"] && env["user"]["id"]
      ) || Screen_Name.read_id!(env["sn"]["screen_name"])
    end

    result = Link.create user_id, args

    case result do
      %{"link"=> _link} ->
        env = JSON_Spec.put(env, "link", result)
      _ ->
        result
    end
    {stack ++ [result], prog, env}
  end

  def link_create(stack, prog, env) do
    {args, prog, env} = JSON_Spec.take(prog, 1, env)
    result            = Link.create env["user"]["id"], args
    case result do
      %{"link"=>_link} ->
        env = JSON_Spec.put(env, "link", result)
      _ ->
        result
    end
    {stack ++ [result], prog, env}
  end

end # === defmodule Link.Spec_Funcs

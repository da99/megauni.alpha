
defmodule Link.Spec_Funcs do

  def create_link(stack, [raw_args | prog], env) do
    {[args], _empty, env} = JSON_Applet.run([], ["data", raw_args], env)

    result = case args do
      [user_id | args] when is_number(user_id) ->
        Link.create user_id, args
      _ ->
        user = JSON_Applet.get(:user, env)
        sn   = JSON_Applet.get(:sn, env)
        user_id = ( user && user["id"]) || Screen_Name.read_id!(sn |> Map.fetch!("screen_name"))
        Link.create user_id, args
    end

    case result do
      %{"link"=> _link} ->
        env = JSON_Applet.put(env, "link", result)
      _ ->
        result
    end
    {stack ++ [result], prog, env}
  end

  def link_create(stack, prog, env) do
    {args, prog, env} = JSON_Applet.take(prog, 1, env)
    result            = Link.create env["user"]["id"], args
    case result do
      %{"link"=>_link} ->
        env = JSON_Applet.put(env, "link", result)
      _ ->
        result
    end
    {stack ++ [result], prog, env}
  end

end # === defmodule Link.Spec_Funcs


defmodule Link.Spec_Funcs do

  def link(stack, prog, env) do
    JSON_Applet.get_by_count(stack, [:link | prog], env)
  end

  def create_link(stack, [raw_args | prog], env) do
    {[args], _empty, env} = JSON_Applet.run([], ["data", raw_args], env)

    {result, user_id, args} = case args do
      [user_id | args] when is_number(user_id) ->
        {Link.create(user_id, args), user_id, args}
      _ ->
        user = JSON_Applet.get(:user, env)
        sn   = JSON_Applet.get(:sn, env)
        user_id = ( user && user["id"]) || Screen_Name.read_id!(sn |> Map.fetch!("screen_name"))
        {Link.create(user_id, args), user_id, args}
    end

    case result do
      {:ok, true} ->
        {:ok, link} = apply(Link, :raw!, [user_id, args])
        env = JSON_Applet.put(env, :link, link)
        {stack ++ [result], prog, env}
    end
  end

end # === defmodule Link.Spec_Funcs

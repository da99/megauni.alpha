
defmodule Link.Spec_Funcs do

  def link(stack, prog, env) do
    JSON_Applet.get_by_count(stack, [:link | prog], env)
  end

  def link_create stack, [raw_args|prog], env do
    user_id = (JSON_Applet.get(:user, env) || JSON_Applet.get!(:sn, env))
              |> Map.fetch!("id")

    {[args], _empty, env} = JSON_Applet.run([], ["data",raw_args], env)
    result = Link.create(user_id, args)
    case result do
      {:ok, row} ->
        env = JSON_Applet.put(env, :link, row)
        {stack ++ [row |> JSON_Applet.to_json_to_elixir], prog, env}
    end
  end # def link_create

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

    end # case

    case result do
      {:ok, true} ->
        {:ok, link} = apply(Link, :raw!, [user_id, args])
        env = JSON_Applet.put(env, :link, link)
        {stack ++ [result], prog, env}
    end # case
  end # def create_link

end # === defmodule Link.Spec_Funcs

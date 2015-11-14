
defmodule User.Spec_Funcs do

  def spec_funcs do
    Map.merge(
      JSON_Applet.func_map(User.Spec_Funcs),
      %{ "user.id =" => :user_id_equals }
    )
  end

  def valid_pass do
    "valid pass word phrase"
  end

  def long_pass_word(stack, [[]|prog], env) do
    { stack ++ [String.duplicate("one two three four five ", 150)], prog, env}
  end

  def user_id_equals stack, [ raw | prog], env do
    {args, _empty, env} = JSON_Applet.run([], raw, env)
    num = List.last args
    user = (JSON_Applet.get(:user, env) || %{})
            |> Map.put("id", num)

    # === We use Map.put instead of JSON_Applet.en
    # === because we don't want to put in a new :user,
    # === only "update" it.
    env = env
          |> Map.put(:user, user)
          |> Map.put(:"user_#{JSON_Applet.get(:user_counter, env)}", user)

    { stack, prog, env }
  end

  def user_id(stack, prog, env) do
    {args, prog, env} = JSON_Applet.take prog, 1, env
    env = JSON_Applet.put :user, %{"id"=> List.last(args)}
    {stack, prog, env}
  end

  def user(stack, [[] | prog], env) do
    u = JSON_Applet.get(:user, env)
    if !u do
      raise "User not found."
    end
    {stack ++ [u], prog, env}
  end

  def user_create(stack, prog, env) do
    {data, prog, env} = JSON_Applet.take(prog, 1, env)
    if Map.has_key?(data, "error") do
      raise "#{inspect data}"
    end

    result = User.create(data) |> JSON_Applet.to_json_to_elixir
    case result do
      ["error", ["user_error", _msg]] ->
        result
      ["ok", u = %{"id"=> _user_id}] ->
        env = JSON_Applet.put(env, :user, u)
      _ -> ["error", ["programmer_error", result]]
    end

    {stack ++ [result], prog, env}
  end

  def create_user(stack, prog, env) do
    user = User.create(%{
      "screen_name"  => Screen_Name.Spec_Funcs.rand_screen_name,
      "pass"         => valid_pass,
      "confirm_pass" => valid_pass
    })

    case user do
      {:ok, u = %{"id"=>_user_id}} ->
        env = JSON_Applet.put(env, :user, Map.put(u, "pass", valid_pass))
    end
    {(stack ++ [user]), prog, env}
  end

end # === defmodule User.Spec_Funcs

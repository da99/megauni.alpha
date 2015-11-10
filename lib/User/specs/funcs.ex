
defmodule User.Spec_Funcs do

  def valid_pass do
    "valid pass word phrase"
  end

  def long_pass_word(stack, prog, env) do
    { stack ++ [String.duplicate("one word ", 150)], prog, env}
  end

  def user_id(stack, prog, env) do
    {args, prog, env} = JSON_Spec.take prog, 1, env
    env = Map.put env, "user", %{"id"=> List.last(args)}
    {stack, prog, env}
  end

  def user_create(stack, prog, env) do
    {data, prog, env} = JSON_Spec.take(prog, 1, env)
    if Map.has_key?(data, "error") do
      raise "#{inspect data}"
    end

    result = User.create data
    case result do
      %{"user_error" => _msg} ->
        result
      %{"id"=> _user_id} ->
        env = JSON_Spec.put(env, "user", result)
    end

    {stack ++ [result], prog, env}
  end

  def create_user(stack, prog, env) do
    user = User.create(%{
      "screen_name"  => Spec_Funcs.rand_screen_name,
      "pass"         => Spec_Funcs.valid_pass,
      "confirm_pass" => Spec_Funcs.valid_pass
    })

    env = Map.put env, "user.pass", Spec_Funcs.valid_pass

    case user do
      %{"error" => msg} ->
        raise "create user: #{msg}"
      %{"id"=>_user_id} ->
        env = JSON_Spec.put(env, "user", user)
        if Map.has_key?(env, :user_count) do
          env = Map.put env, :user_count, env.user_count + 1
        else
          env = Map.put env, :user_count, 1
        end
        env = JSON_Spec.put(env, "user_#{env.user_count}", user)
      _ ->
        raise "Unknown error: #{inspect user}"
    end
    {(stack ++ [user]), prog, env}
  end

end # === defmodule User.Spec_Funcs

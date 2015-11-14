
defmodule Log_In.Spec_Funcs do

  def log_in data, stack, prog, env do
    {num, prog, env} = case prog do
      [[] | prog] ->
        {1, prog, env}

      [[num] | prog] when is_number(num) ->
        {num, prog, env}

      [[str] | prog] when is_binary(str) ->
        {[str], _empty, env} = JSON_Applet.run([], [str], env)
        {String.to_integer(str), prog, env}

    end

    attempts = Enum.map 1..num, fn(_x) ->
      Log_In.attempt(data)
      |> JSON_Applet.to_json_to_elixir
    end
    {stack ++ attempts, prog, env}
  end

  def log_in_attempt(stack, prog, env) do
    {arg, prog, env} = JSON_Applet.take(prog, 1, env)
    stack = stack ++ [Log_In.attempt(arg) |> JSON_Applet.to_json_to_elixir]
    {stack, prog, env}
  end

  def log_in_reset_all(stack, prog, env) do
    Log_In.reset_all
    {stack, prog, env}
  end

  def bad_log_in(stack, prog, env) do
    sn = JSON_Applet.get!(:sn, env)

    {stack, prog, env} = %{
      "pass"        => "bad pass word",
      "screen_name" => Map.fetch!(sn,"screen_name"),
      "ip"          => "127.0.0.1"
    } |> log_in(stack, prog, env)

    last  = stack |> List.last |> JSON_Applet.to_json_to_elixir
    stack = List.delete_at(stack, Enum.count(stack) - 1)

    {stack ++ [last], prog, env}
  end

  def good_log_in(stack, prog, env) do
    sn = JSON_Applet.get!(:sn, env)
    %{
      "pass"        => User.Spec_Funcs.valid_pass,
      "screen_name" => sn["screen_name"],
      "ip"          => "127.0.0.1"
    } |> log_in(stack, prog, env)
  end

  def log_in_attempts_aged(stack, [[arg] | prog], env) do
    {:ok, rows} = Log_In.aged arg

    {stack ++ [Enum.count rows], prog, env}
  end

  def all_log_in_attempts_old(_data, _env) do
    {:ok, _} = Megauni.SQL.query(
      "UPDATE log_in SET at = at + '25 hours'::interval",
      []
    )
  end

end # === defmodule Log_In.Spec_Funcs

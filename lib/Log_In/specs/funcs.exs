
defmodule Log_In.Spec_Funcs do

  def log_in data, stack, prog, env do
    if is_list(List.first(prog)) do
      [[num] | prog] = prog
      {num, env} = JSON_Spec.compile(num, env)
      if !is_number(num) do
        num = String.to_integer(num)
      end
    else
      num = 1
    end

    attempts = Enum.map 1..num, fn(_x) ->
      Log_In.attempt data
    end
    {stack ++ attempts, prog, env}
  end

  def log_in_attempt(stack, prog, env) do
    {arg, prog, env} = JSON_Spec.take(prog, 1, env)
    stack = stack ++ [Log_In.attempt(arg)]
    {stack, prog, env}
  end

  def log_in_reset_all(stack, prog, env) do
    Log_In.reset_all
    {stack, prog, env}
  end

  def bad_log_in(stack, prog, env) do
    {stack, prog, env} = Spec_Funcs.log_in( %{
      "pass"        => "bass pass",
      "screen_name" => env["sn"]["screen_name"],
      "ip"          => "127.0.0.1"
    }, stack, prog, env)

    {stack ++ [{:JSON_Spec, :ignore_last_error}], prog, env}
  end

  def good_log_in(stack, prog, env) do
    Spec_Funcs.log_in %{
      "pass"        => Spec_Funcs.valid_pass,
      "screen_name" => env["sn"]["screen_name"],
      "ip"          => "127.0.0.1"
    }, stack, prog, env
  end

  def log_in_attempts_aged(stack, prog, env) do
    [[arg] | prog] = prog
    {:ok, %{:num_rows=>count}} = Log_In.aged arg

    {stack ++ [count], prog, env}
  end

  def all_log_in_attempts_old(_data, _env) do
    {:ok, _} = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      "UPDATE log_in SET at = at + '25 hours'::interval",
      []
    )
  end

end # === defmodule Log_In.Spec_Funcs

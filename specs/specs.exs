

models = if Enum.empty?(System.argv) do
  {raw, _exit} = System.cmd Path.expand("bin/megauni"), ["model_list"]
  raw |> String.strip |> String.split
else
  System.argv
end

files = Path.wildcard("lib/{#{models |> Enum.join ","}}/specs/*.json")

defmodule Spec_Funcs do

  def rand_screen_name do
    {_mega, sec, micro} = :erlang.timestamp
    "SN_#{sec}_#{micro}"
  end # === def rand_screen_name

  def valid_pass do
    "valid pass word phrase"
  end

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

    attempts = Enum.map 1..num, fn(x) ->
      Log_In.attempt data
    end
    [stack ++ attempts, prog, env]
  end

end # === defmodule Megauni.Specs

env = %{

  "rand screen_name" => fn(env) ->
    {_mega, sec, micro} = :erlang.timestamp
    sn = "SN_#{sec}_#{micro}"
    { sn, Map.put(env, "screen_name", sn) }
  end,

  "long_pass_word" => fn(env) ->
    { String.duplicate("one word ", 150), env}
  end,

  "Screen_Name.create" => fn(stack, prog, env) ->
    [data | prog] = prog
    result        = Screen_Name.create data

    case result do
      %{"error" => msg} ->
        result

      %{"screen_name"=>_sn} ->
        env = JSON_Spec.put(env, "sn", result)
    end

    [stack ++ [result], prog, env]
  end, # === Screen_Name.create

  "Screen_Name.read" => fn(stack, prog, env) ->
    [data | prog] = prog
    result        = Screen_Name.read data

    In.spect result
    case result do
      %{"error" => msg} ->
        result
      %{"screen_name"=>_sn} ->
        env = JSON_Spec.put(env, "sn", result)
    end

    [stack ++ [result], prog, env]
  end, # === Screen_Name.read

  "User.create" => fn(stack, prog, env) ->
    [data | prog] = prog
    if Map.has_key?(data, "error") do
      raise "#{inspect data}"
    end
    result = User.create data
    case result do
      %{"error" => msg} ->
        result
      %{"id"=>user_id} ->
        env = JSON_Spec.put(env, "user", result)
    end

    [stack ++ [result], prog, env]
  end,

  "Log_In.attempt" => fn(stack, prog, env) ->
    [arg, prog, env] = JSON_Spec.take(prog, 1, env)
    stack = stack ++ [Log_In.attempt(arg)]
    [stack, prog, env]
  end,

  "Log_In.reset_all" => fn(stack, prog, env) ->
    Log_In.reset_all
    [stack, prog, env]
  end,

  "bad_log_in" => fn(stack, prog, env) ->
    Spec_Funcs.log_in %{
      "pass"        => "bass pass",
      "screen_name" => env["sn"]["screen_name"],
      "ip"          => "127.0.0.1"
    }, stack, prog, env
  end,

  "good_log_in" => fn(stack, prog, env) ->
    Spec_Funcs.log_in %{
      "pass"        => Spec_Funcs.valid_pass,
      "screen_name" => env["sn"]["screen_name"],
      "ip"          => "127.0.0.1"
    }, stack, prog, env
  end,

  "log_in_attempts aged" => fn(stack, prog, env) ->
    [[arg] | prog] = prog
    {:ok, _} = Log_In.aged arg
    [stack, prog, env]
  end,

  "create user" => fn(stack, prog, env) ->
    user = User.create(%{
      "screen_name"  => Spec_Funcs.rand_screen_name,
      "pass"         => Spec_Funcs.valid_pass,
      "confirm_pass" => Spec_Funcs.valid_pass
    })

    env = Map.put env, "user.pass", Spec_Funcs.valid_pass

    case user do
      %{"error" => msg} ->
        raise "create user: #{msg}"
      %{"id"=>user_id} ->
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
    [(stack ++ [user]), prog, env]
  end,

  "create screen_name" => fn(stack, prog, env) ->
    arg = if Map.has_key?(env, "user") do
      %{
        "screen_name" => Spec_Funcs.rand_screen_name,
        "owner_id"     => env["user"]["id"]
      }
    else
      %{ "screen_name" => Spec_Funcs.rand_screen_name }
    end

    sn = Screen_Name.create(arg)

    case sn do
      %{"error" => msg} ->
        raise "create screen_name: #{msg}"
      %{"screen_name"=>name} ->
        env = JSON_Spec.put(env, "sn", sn)
        if Map.has_key?(env, :sn_count) do
          env = Map.put env, :sn_count, env.sn_count + 1
        else
          env = Map.put env, :sn_count, 1
        end
        env = JSON_Spec.put(env, "sn_#{env.sn_count}", sn)
      _ ->
        raise "Unknown error: #{inspect sn}"
    end
    [(stack ++ [sn]), prog, env]
  end,

  "all log_in_attempts old" => fn(data, env) ->
    {ok, _} = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      "UPDATE log_in SET at = at + '25 hours'::interval",
      []
    )
  end

}

Enum.each(files, &(JSON_Spec.run_file(&1, env)))





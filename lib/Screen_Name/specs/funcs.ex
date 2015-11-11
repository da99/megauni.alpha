
defmodule Screen_Name.Spec_Funcs do

  def rand_screen_name do
    {_mega, sec, micro} = :erlang.timestamp
    "SN_#{sec}_#{micro}"
  end # === def rand_screen_name

  def rand_screen_name(stack, [[] | prog], env) do
    {_mega, sec, micro} = :erlang.timestamp
    sn = "SN_#{sec}_#{micro}"
    env = Map.put(env, :screen_name, sn)
    {stack ++ [sn], prog, env}
  end

  def read_homepage(stack, prog, env) do
    cards = Screen_Name.read_homepage_cards(
      env["user"]["id"],
      env["sn"]["screen_name"]
    )
    JSON_Applet.put(env, "cards", cards);
    {stack ++ [cards], prog, env}
  end

  def read_news_card(stack, prog, env) do
    user_id = (
      env["user"] && env["user"]["id"]
    ) || Screen_Name.read_id!(env["sn"]["screen_name"])

    result = if prog |> List.first |> is_list do
      {args, prog, env} = JSON_Applet.take(prog, 1, env)
      Screen_Name.read_news_card user_id, args
    else
      Screen_Name.read_news_card user_id
    end

    case result do
      x when is_list(x) ->
        env = JSON_Applet.put(env, "news_cards", result)
      _ ->
        result
    end
    {stack ++ [result], prog, env}
  end

  def screen_name(stack, [[]], env) do
    {stack ++ [JSON_Applet.get(:screen_name, env)], [], env}
  end

  def screen_name_create(stack, prog, env) do
    {[new_name], prog, env} = JSON_Applet.take(prog, 1, env)
    user_id = if env["user"] do
      env["user"]["id"]
    else
      nil
    end

    result  = Screen_Name.create user_id, new_name
    case result do
      %{"screen_name"=>_sn} ->
        env = JSON_Applet.put(env, :sn, result)

      _ ->
        result
    end

    {stack ++ [JSON_Applet.to_json_to_elixir(result)], prog, env}
  end # === Screen_Name.create

  def screen_name_read(stack, prog, env) do
    {data, prog, env} = JSON_Applet.take(prog, 1, env)
    rows          = Screen_Name.read data

    case rows do
      %{"error" => _msg} ->
        {stack ++ [rows], prog, env}

      %{"screen_name"=>_sn} ->
        {fin, env} = Enum.reduce rows, {nil, env}, fn(r, {_fin, env}) ->
          env = JSON_Applet.put(env, "sn", r)
          {r, env}
        end
        {stack ++ [fin], prog, env}
    end
  end # === Screen_Name.read

  def sn stack, [[]|prog], env do
    sn stack, [[1]|prog], env
  end

  def sn stack, prog, env do
    [[num] | prog] = prog
    key = String.to_atom("sn_#{num}")
    tuple = JSON_Applet.get(key, env)
    val = case tuple do
      {:ok, row} -> row
      _ -> tuple
    end
    {stack ++ [val], prog, env}
  end

  def screen_name_raw!(stack, prog, env) do
    {[name], prog, env} = JSON_Applet.take(prog, 1, env)
    result            = Screen_Name.raw! name

    case result do
      {:error, {:user_error, _msg}} ->
        result

      {:ok, %{"screen_name"=>_sn}} ->
        env = JSON_Applet.put(env, :sn, result)
    end

    {stack ++ [result |> JSON_Applet.to_json_to_elixir], prog, env}
  end # === Screen_Name.read_one

  def create_screen_name(stack, prog, env) do
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
      %{"screen_name"=> _name} ->
        env = JSON_Applet.put(env, "sn", sn)
        if Map.has_key?(env, :sn_count) do
          env = Map.put env, :sn_count, env.sn_count + 1
        else
          env = Map.put env, :sn_count, 1
        end
        env = JSON_Applet.put(env, "sn_#{env.sn_count}", sn)
      _ ->
        raise "Unknown error: #{inspect sn}"
    end
    {(stack ++ [sn]), prog, env}
  end

  def update_privacy(stack, prog, env) do
    {args, prog, env} = JSON_Applet.take(prog, 1, env)
    name = env["sn"]["screen_name"]
    id   = Screen_Name.select_id(name)
    {:ok, _answer} = Screen_Name.run id, ["update screen_name privacy", [name, List.last(args)]]
    {stack, prog, env}
  end

end # === defmodule Screen_Name.Spec.Funcs

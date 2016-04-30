
defmodule Screen_Name.Spec_Funcs do

  def sn stack, prog, env do
    JSON_Applet.get_by_count(stack, [:sn | prog], env)
  end

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

  def read_homepage(stack, [[]|prog], env) do
    cards = Screen_Name.read_homepage_cards(
      JSON_Applet.get!(:user, env)["id"],
      JSON_Applet.get!(:sn, env)["screen_name"]
    )

    {stack ++ [cards], prog, JSON_Applet.put(env, :cards, cards)}
  end

  def read_news_card(stack, [args | prog], env) do
    user = JSON_Applet.get(:user, env)
    sn   = JSON_Applet.get(:sn, env)
    user_id = (
      user && user["id"]
    ) || Screen_Name.read_id!(Map.fetch! sn, "screen_name")

    result = if Enum.empty?(args) do
      Screen_Name.read_news_card user_id
    else
      {[args], prog, env} = JSON_Applet.run([], ["data", args], env)
      Screen_Name.read_news_card user_id, args
    end

    case result do
      x when is_list(x) ->
        env = JSON_Applet.put(env, :news_cards, result)
      _ ->
        result
    end

    {stack ++ [result |> JSON_Applet.to_json_to_elixir], prog, env}
  end

  def screen_name(stack, [[]], env) do
    {stack ++ [JSON_Applet.get(:screen_name, env)], [], env}
  end

  def screen_name_create(stack, prog, env) do
    {[new_name], prog, env} = JSON_Applet.take(prog, 1, env)

    user_id = JSON_Applet.get(:user, env, %{"id"=>nil})
              |> Map.get("id")

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

  def screen_name_raw!(stack, prog, env) do
    {[name], prog, env} = JSON_Applet.take(prog, 1, env)
    result            = Screen_Name.raw! name

    case result do
      {:error, {:user_error, _msg}} ->
        result

      {:ok, sn = %{"screen_name"=>_sn}} ->
        env = JSON_Applet.put(env, :sn, sn)
    end

    {stack ++ [result |> JSON_Applet.to_json_to_elixir], prog, env}
  end # === Screen_Name.read_one

  def create_screen_name(stack, prog, env) do
    user = JSON_Applet.get(:user, env)
    sn = if user do
      Screen_Name.create(user["id"], rand_screen_name)
    else
      Screen_Name.create(nil, rand_screen_name)
    end

    case sn do
      {:ok, sn_map = %{"screen_name"=> name}} ->

        # === Put :id field just in case it is needed later:
        sn_map = Map.put(
          sn_map, "id", Screen_Name.read_id!(name)
        )
        env = JSON_Applet.put(env, :sn, sn_map)
    end

    {(stack ++ [sn |> JSON_Applet.to_json_to_elixir]), prog, env}
  end

  def update_privacy(stack, prog, env) do
    {args, prog, env} = JSON_Applet.take(prog, 1, env)
    name = :sn |> JSON_Applet.get(env) |> Map.get("screen_name")
    id   = Screen_Name.select_id(name)

    {:ok, _answer} = Screen_Name.run id, ["update screen_name privacy", [name, List.last(args)]]

    {stack, prog, env}
  end

end # === defmodule Screen_Name.Spec.Funcs



models = if Enum.empty?(System.argv) do
  {raw, _exit} = System.cmd Path.expand("bin/megauni"), ["model_list"]
  raw |> String.strip |> String.split
else
  System.argv
end

files = Enum.reduce models, [], fn(mod, acc) ->
   cond do
     File.exists?(mod) ->
       acc ++ [mod]
     mod =~ ~r/[\*|\/]/ ->
       acc ++ Path.wildcard("lib/#{mod}.json")
     true ->
       acc ++ Path.wildcard("lib/#{mod}/specs/*.json")
   end
end


if Enum.empty?(files) do
  Process.exit self, "!!! No specs found: #{inspect System.argv}. Exiting..."
end

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

    attempts = Enum.map 1..num, fn(_x) ->
      Log_In.attempt data
    end
    {stack ++ attempts, prog, env}
  end

  def rand_screen_name(stack, prog, env) do
    {_mega, sec, micro} = :erlang.timestamp
    sn = "SN_#{sec}_#{micro}"
    env = Map.put(env, "screen_name", sn)
    {stack ++ [sn], prog, env}
  end

  def long_pass_word(stack, prog, env) do
    { stack ++ [String.duplicate("one word ", 150)], prog, env}
  end

  def query(stack, prog, env) do
    {query, prog, env} = JSON_Spec.take(prog, 1, env)
    {:ok, %{columns: keys, rows: rows}} = Ecto.Adapters.SQL.query( Megauni.Repos.Main, query, [] )
    rows = Enum.map rows, fn(r) ->
      Enum.reduce Enum.zip(keys,r), %{}, fn({key, val}, map) ->
        Map.put map, key, val
      end
    end
    {stack ++ [rows], prog, env}
  end

  def repeat(stack, prog, env) do
    {[num | list], prog, env} = JSON_Spec.take(prog, 1, env)
    {env, new_stack} = Enum.reduce 0..num, {env, []}, fn(_i, {env, _stack}) ->
      {stack, env} = JSON_Spec.run_list(list, env)
      {env, stack ++ [List.last(stack)]}
    end

    {stack ++ new_stack, prog, env}
  end

  def array(stack, prog, env) do
    { arr, prog, env } = JSON_Spec.take(prog, 1, env)
    {stack ++ [arr], prog, env}
  end

  def length(stack, prog, env) do
    {stack ++ [stack |> List.last |> Enum.count], prog, env}
  end

  def pluck(stack, prog, env) do
    {[key], prog, env} = JSON_Spec.take(prog, 1, env)
    results = Enum.map List.last(stack), fn(x) ->
      x[key]
    end
    {stack ++ [results], prog, env}
  end

  def unique(stack, prog, env) do
    arr = List.last(stack)
    { stack ++ [Enum.uniq(arr)], prog, env }
  end

  def create_card(stack, prog, env) do
    if (prog |> List.first |> is_map) do
      {data, prog, env} = JSON_Spec.take(prog, 1, env)
    else
      data = %{
        "owner_id"          => env["user"]["id"],
        "owner_screen_name" => env["sn"]["screen_name"],
        "privacy"           => "WORLD READABLE",
        "code"              => [%{"cmd": "time"}]
      }
    end

    result = Card.create data
    case result do
      %{"id"=> _card} ->
        env = JSON_Spec.put(env, "card", result)
      _ ->
        result
    end

    {stack ++ [result], prog, env}
  end

  def create_link(stack, prog, env) do
    {args, prog, env} = JSON_Spec.take(prog, 1, env)

    if (args |> List.first |> is_number) do
      [user_id | args] = args
    else
      user_id = (
        env["user"] && env["user"]["id"]
      ) || Screen_Name.read_id!(env["sn"]["screen_name"])
    end

    result = Link.create user_id, args

    case result do
      %{"link"=> _link} ->
        env = JSON_Spec.put(env, "link", result)
      _ ->
        result
    end
    {stack ++ [result], prog, env}
  end

  def read_homepage(stack, prog, env) do
    cards = Screen_Name.read_homepage_cards(
      env["user"]["id"],
      env["sn"]["screen_name"]
    )
    JSON_Spec.put(env, "cards", cards);
    {stack ++ [cards], prog, env}
  end

  def read_news_card(stack, prog, env) do
    user_id = (
      env["user"] && env["user"]["id"]
    ) || Screen_Name.read_id!(env["sn"]["screen_name"])

    result = if prog |> List.first |> is_list do
      {args, prog, env} = JSON_Spec.take(prog, 1, env)
      Screen_Name.read_news_card user_id, args
    else
      Screen_Name.read_news_card user_id
    end

    case result do
      x when is_list(x) ->
        env = JSON_Spec.put(env, "news_cards", result)
      _ ->
        result
    end
    {stack ++ [result], prog, env}
  end

  def user_id(stack, prog, env) do
    {args, prog, env} = JSON_Spec.take prog, 1, env
    env = Map.put env, "user", %{"id"=> List.last(args)}
    {stack, prog, env}
  end

  def type_ids(stack, prog, env) do
    ids = Regex.scan(
      ~r/RETURN\s+(\d+)\s?;/,
      File.read!("lib/Megauni/migrates/__-02-link_type_id.sql")
    )
    |> Enum.map(fn([_match, id]) ->
      id
    end)

    {stack ++ [ids], prog, env}
  end

  def link_create(stack, prog, env) do
    {args, prog, env} = JSON_Spec.take(prog, 1, env)
    result            = Link.create env["user"]["id"], args
    case result do
      %{"link"=>_link} ->
        env = JSON_Spec.put(env, "link", result)
      _ ->
        result
    end
    {stack ++ [result], prog, env}
  end

  def screen_name_create(stack, prog, env) do
    {data, prog, env} = JSON_Spec.take(prog, 1, env)
    result            = Screen_Name.create data

    case result do
      %{"screen_name"=>_sn} ->
        env = JSON_Spec.put(env, "sn", result)

      _ ->
        result
    end

    {stack ++ [result], prog, env}
  end # === Screen_Name.create

  def screen_name_read(stack, prog, env) do
    {data, prog, env} = JSON_Spec.take(prog, 1, env)
    rows          = Screen_Name.read data

    case rows do
      %{"error" => _msg} ->
        {stack ++ [rows], prog, env}

      %{"screen_name"=>_sn} ->
        {fin, env} = Enum.reduce rows, {nil, env}, fn(r, {_fin, env}) ->
          env = JSON_Spec.put(env, "sn", r)
          {r, env}
        end
        {stack ++ [fin], prog, env}
    end
  end # === Screen_Name.read

  def screen_name_read_one(stack, prog, env) do
    {data, prog, env} = JSON_Spec.take(prog, 1, env)
    result            = Screen_Name.read_one data

    case result do
      %{"user_error" => _msg} ->
        result

      %{"screen_name"=>_sn} ->
        env = JSON_Spec.put(env, "sn", result)
    end

    {stack ++ [result], prog, env}
  end # === Screen_Name.read_one

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

  def lookup_kv(k, env) do
    cond do
      x = Regex.run(~r/^card_(.)?\.linked_at$/, k) ->
        id = env["card_#{List.last(x)}"]["id"]
        row = Megauni.Model.query(
          """
           SELECT created_at AS linked_at FROM link
           WHERE type_id = name_to_type_id('LINK')
             AND  a_id = $1 AND a_type_id = name_to_type_id('CARD')
             AND  b_type_id = name_to_type_id('SCREEN_NAME')
           ORDER BY id DESC
           LIMIT 1
         """, [id]
        ) |> Megauni.Model.one_row;
        {row["linked_at"], env}

      x = Regex.run(~r/^sn_(.)?\.id$/, k) ->
        name = env["sn_#{List.last(x)}"]["screen_name"]
        {Screen_Name.read_id!(name), env}

      k == "sn.id" ->
        name = env["sn"]["screen_name"]
        {Screen_Name.read_id!(name), env}


      true ->
        {k, env}
    end # === cond
  end

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
    {(stack ++ [sn]), prog, env}
  end

  def update_privacy(stack, prog, env) do
    {args, prog, env} = JSON_Spec.take(prog, 1, env)
    name = env["sn"]["screen_name"]
    id   = Screen_Name.select_id(name)
    {:ok, _answer} = Screen_Name.run id, ["update screen_name privacy", [name, List.last(args)]]
    {stack, prog, env}
  end

  def all_log_in_attempts_old(_data, _env) do
    {:ok, _} = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      "UPDATE log_in SET at = at + '25 hours'::interval",
      []
    )
  end

end # === defmodule Spec_Funcs


JSON_Spec.run_files(files, Spec_Funcs)





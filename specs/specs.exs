

models = if Enum.empty?(System.argv) do
  {raw, _exit} = System.cmd Path.expand("bin/megauni"), ["model_list"]
  raw |> String.strip |> String.split
else
  System.argv
end

files = Path.wildcard("lib/{#{models |> Enum.join ","}}/specs/*.json")
env = %{

  "rand screen_name" => fn(env) ->
    {_mega, sec, micro} = :erlang.timestamp
    sn = "SN_#{sec}_#{micro}"
    { sn, Map.put(env, "screen_name", sn) }
  end,

  "long_pass_word" => fn(env) ->
    { String.duplicate("one word ", 150), env}
  end,

  "Screen_Name.create" => fn(data, env) ->
    if Map.has_key?(data, "error") do
      raise "#{inspect data}"
    end
    result = Screen_Name.create data
    case result do
      %{"error" => msg} ->
        {%{"error"=>msg}, Map.put(env, "error", msg)}
      %{"screen_name"=>_sn} ->
        {result, JSON_Spec.put(env, "sn", result)}
      _ -> raise "Unknown error: #{inspect result}"
    end
  end,

  "Screen_Name.read" => fn(data, env) ->
    result = Screen_Name.read data
    case result do
      %{"error" => msg} ->
        {%{"error"=>msg}, Map.put(env, "error", msg)}
      %{"screen_name"=>_sn} ->
        {result, JSON_Spec.put(env, "sn", result)}
      _ ->
        {result, JSON_Spec.put(env, "sn", result)}
        # raise "Not found: #{inspect data} result: #{inspect result}"
    end
  end,

  "User.create" => fn(data, env) ->
    if Map.has_key?(data, "error") do
      raise "#{inspect data}"
    end
    result = User.create data
    case result do
      %{"error" => msg} ->
        {%{"error"=>msg}, Map.put(env, "error", msg)}
      %{"id"=>user_id} ->
        {result, JSON_Spec.put(env, "user", result)}
      _ -> raise "Unknown error: #{inspect result}"
    end
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





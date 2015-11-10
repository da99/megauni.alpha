
defmodule Megauni.Spec_Funcs do

  def query(stack, prog, env) do
    {query, prog, env} = JSON_Applet.take(prog, 1, env)
    {:ok, %{columns: keys, rows: rows}} = Ecto.Adapters.SQL.query( Megauni.Repos.Main, query, [] )
    rows = Enum.map rows, fn(r) ->
      Enum.reduce Enum.zip(keys,r), %{}, fn({key, val}, map) ->
        Map.put map, key, val
      end
    end
    {stack ++ [rows], prog, env}
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

end # === defmodule Megauni.Spec_Funcs

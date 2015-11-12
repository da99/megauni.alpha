


defmodule Screen_Name do
  # === These values are here for convenience,
  #     but the canonical source is in the migrations: 00.-before-insert.sql
  @me_only    1  # === Only the owner can read it.
  @list       2  # === You need to be on the list of allowed people.
  @public     3  # === Everyone can read it.

  @begin_at_or_hash  ~r/\A(\@|\#)/
  @all_white_space   ~r/\s+/

  def raw! raw_name do
    if !System.get_env("IS_DEV") do
      raise "Not on a dev machine"
    end

    Megauni.SQL.query("SELECT * FROM top_level_screen_name($1) AS id;", [raw_name])
    |> Megauni.SQL.one_row
  end

  def canonize list_or_binary do
    case list_or_binary do
      list when is_list(list) ->
        Enum.map(list, fn (v) -> canonize(v) end)

      str when is_binary(str) ->
        str = str
        |> String.strip
        |> String.upcase
        |> (&Regex.replace(@begin_at_or_hash, &1, '')).()
        |> (&Regex.replace(@all_white_space, &1, '-')).()
    end # === case

  end # === def canonize_screen_name

  def select_id name do
    Megauni.SQL.query("SELECT screen_name_id($1) AS id;", [name])
    |> Megauni.SQL.one_row
    |> DA_3001.ok_second
    |> Map.get("id")
  end

  def run user_id, [ action, args ] do
    case action do
      "update screen_name privacy" ->
        {:ok, _val} = Megauni.SQL.query(
          "SELECT * FROM update_screen_name_privacy( $1, $2, $3 );",
          [user_id] ++ args
        )
        {:ok, true}
    end
  end # === def run

  def read_id! raw_name do
    result = Megauni.SQL.query(
      "SELECT id FROM top_level_screen_name($1);",
      [raw_name]
    )

    case result do
      {:ok, [row]} ->
        Map.fetch!(row, "id")
      _ ->
        raise "screen_name not found: #{inspect raw_name}"
    end
  end

  def read data do
    Megauni.SQL.query(
      "SELECT * FROM screen_name_read($1);",
      [data["screen_name"]]
    )
  end

  def read_news_card user_id do
    Megauni.SQL.query(
      "SELECT * FROM news_card($1) LIMIT 100;",
      [user_id]
    )
  end

  def read_news_card user_id, [sn] do
    Megauni.SQL.query(
      "SELECT * FROM news_card($1, $2) LIMIT 100;",
      [user_id, sn]
    )
  end

  def read_homepage_cards user_id, sn do
    Megauni.SQL.query(
      "SELECT * FROM homepage_card($1, $2) LIMIT 100;",
      [user_id, sn]
    )
  end

  def clean_screen_name sn do
    if !sn do
      sn = ""
    end

    if String.length(sn > 30) do
      %{"error": "screen_name: max 30"}
    else
      sn
    end
  end

  def create user_id, new_name do

    result = Megauni.SQL.query(
      "SELECT screen_name
      FROM screen_name_insert($1, $2);",
      [user_id, new_name]
    )

    if Megauni.SQL.is_too_long?(result) do
      {:error, {:user_error, "screen_name: max #{Megauni.SQL.max_length result}"}}
    else
      Megauni.SQL.one_row(result, "screen_name")
    end
  end

  def is_allowed_to_post_to sn do
    Link.create([
      owner_id: sn.data[:owner_id],
      type_id: "ALLOW_TO_LINK",
      asker_id: :id,
      giver_id: sn.id
    ])
  end

  def is_allowed_to_read sn do
    Link.create(
      owner_id: sn.id,
      type_id:  "ALLOW_ACCESS_SCREEN_NAME",
      asker_id: :id,
      giver_id: sn.id
    )
  end

  def is_blocked_from sn, id do
    Link.create(
      owner_id: sn.id,
      type_id: "BLOCK_ACCESS_SCREEN_NAME",
      asker_id: id,
      giver_id: sn.id
    )
  end

  def comments_on computer, msg do
    comment = Computer.computer([msg: msg])
    Link.create(
      owner_id: :id,
      type_id:  "COMMENT",
      asker_id: comment.id,
      giver_id: computer.id
    )
    comment
  end

  def to_href do
    "/@#{:screen_name}"
  end

  def href sn do
    "/@#{sn.screen_name}"
  end

  def clean(r, raw_data) do
    # unique_index 'screen_name_unique_idx', "Screen name already taken: {{val}}"
    Megauni.SQL.grab_keys_from_raw_data(r, raw_data, Screen_Name.CLEAN_KEYS)
  end

  def on_error e, this do
    if (this.is_new && ~r/screen_name_unique_idx/.test(e.message)) do
      this.error_msg('screen_name', 'Screen name is taken.')
    end
  end

end # === defmodule Screen_Name










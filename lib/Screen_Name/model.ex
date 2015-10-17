


defmodule Screen_Name do
  # === These values are here for convenience,
  #     but the canonical source is in the migrations: 00.-before-insert.sql
  @me_only    1  # === Only the owner can read it.
  @list       2  # === You need to be on the list of allowed people.
  @public     3  # === Everyone can read it.

  @begin_at_or_hash  ~r/\A(\@|\#)/
  @all_white_space   ~r/\s+/

  def canonize str do
    cond do
      is_list(str) ->
        Enum.map(str, fn (v) -> canonize(v) end)
      is_binary(str) ->
        str = str
        |> String.strip
        |> String.upcase
        |> (&Regex.replace(@begin_at_or_hash, &1, '')).()
        |> (&Regex.replace(@all_white_space, &1, '-')).()
    end

  end # === def canonize_screen_name

  def read data do
    Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      "SELECT * FROM screen_name_read($1);",
      [data["screen_name"]]
    )
    |> Megauni.Model.applet_results("screen_name")
    |> List.first
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

  def create raw_data do
    vals = Enum.into(raw_data, %{"owner_id"=>nil})

    Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      "SELECT screen_name
      FROM screen_name_insert($1, $2);",
      [vals["owner_id"], vals["screen_name"]]
    )
    |> Megauni.Model.applet_results("screen_name")
    |> List.first
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
    Megauni.Model.grab_keys_from_raw_data(r, raw_data, Screen_Name.CLEAN_KEYS)
  end

  def on_error e, this do
    if (this.is_new && ~r/screen_name_unique_idx/.test(e.message)) do
      this.error_msg('screen_name', 'Screen name is taken.')
    end
  end

end # === defmodule Screen_Name













defmodule Screen_Name do
  # === These values are here for convenience,
  #     but the canonical source is in the migrations: 00.-before-insert.sql
  @ME_ONLY    1  # === Only the owner can read it.
  @LIST       2  # === You need to be on the list of allowed people.
  @PUBLIC     3  # === Everyone can read it.

  @BEGIN_AT_OR_HASH  ~r/\A(\@|\#)/
  @ALL_WHITE_SPACE   ~r/\s+/

  def canonize str do
    cond do
      is_list(str) ->
        Enum.map(str, fn (v) -> canonize(v) end)
      is_binary(str) ->
        str = str
        |> String.strip
        |> String.upcase
        |> (&Regex.replace(@BEGIN_AT_OR_HASH, &1, '')).()
        |> (&Regex.replace(@ALL_WHITE_SPACE, &1, '-')).()
    end

  end # === def canonize_screen_name

  def is_allowed_to_post_to sn do
    Link.create(
      owner_id: sn.data[:owner_id],
      type_id: "ALLOW_TO_LINK",
      asker_id: id,
      giver_id: sn.id
    )
  end

  def is_allowed_to_read sn do
    Link.create(
      owner_id: sn.id,
      type_id:  "ALLOW_ACCESS_SCREEN_NAME",
      asker_id: id,
      giver_id: sn.id
    )
  end

  def is_blocked_from sn, id
    Link.create(
      owner_id: sn.id,
      type_id: "BLOCK_ACCESS_SCREEN_NAME",
      asker_id: id,
      giver_id: sn.id
    )
  end

  def comments_on computer, msg do
    comment = computer({msg: msg})
    Link.create(
      owner_id: id,
      type_id:  'COMMENT',
      asker_id: comment.id,
      giver_id: computer.id
    )
    comment
  end

  def to_href
    "/@#{screen_name}"
  end

  def href sn do
    "/@#{sn.screen_name}"
  end

  def clean meta do
    if (meta.is_new) do
      if (!(VALID.test(val)))
      return this.error_msg(KEY, VALID_ENGLISH);

      for (let regexp of BANNED_SCREEN_NAMES) {
        if (regexp.test(val))
        return this.error_msg(KEY, 'Screen name is taken.');
      }

      this.clean[KEY] = val;
      this.clean.display_name = val;
      # unique_index 'screen_name_unique_idx', "Screen name already taken: {{val}}"
    end # === meta.is_new

  end # === def clean

  def on_error e do
    if (this.is_new() && /screen_name_unique_idx/.test(e.message))) do
      this.error_msg('screen_name', 'Screen name is taken.')
    end
  end


end # === defmodule Screen_Name













defmodule Screen_Name do
  @World_Read_Id   1
  @Private_Read_Id 2
  @Not_Read_Id     3
  @SCREEN_NAME_KEYS [
    :screen_name_id, :publisher_id, :owner_id, :author_id, :follower_id
  ]
  @BEGIN_AT_OR_HASH  ~r/\A(\@|\#)/
  @ALL_WHITE_SPACE   ~r/\s+/

  @ME_ONLY    1
  @LIST       2
  @PUBLIC     3

  @VALID                ~r/^[a-zA-Z0-9\-\_\.]{4,30}$/
  @VALID_ENGLISH        "Screen name must be 4 to 30 characters: numbers, letters, underscores, dash, or periods."
  @BANNED_SCREEN_NAMES  [
    ~r/^MEGAUNI/i,
    ~r/^MINIUNI/i,
    ~r/^OKDOKI/i,
    ~r/\A(ME|MINE|MY|MI|i)\z/i,
    ~r/^PET-/i,
    ~r/^BOT-/i,
    ~r/^okjak/i,
    ~r/^okjon/i,
    ~r/^(ONLINE|CONTACT|INFO|OFFICIAL|ABOUT|NEWS|HOME)\z/i,
    ~r/^(UNDEFINED|DEF|SEX|SEXY|XXX|TED|LARRY)\z/i,
    ~r/^[.]+-COLA\z/i
  ]


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
      :owner_id =>sn.data[:owner_id],
      :type_id   =>Link::ALLOW_TO_LINK,
      :asker_id  =>id,
      :giver_id =>sn.id
    )
  end

  def is_allowed_to_read sn do
    Link.create(
      owner_id: sn.id,
      type_id: Link::ALLOW_ACCESS_SCREEN_NAME,
      asker_id: id,
      giver_id: sn.id
    )
  end

  def is_blocked_from sn
    Link.create(
      owner_id: sn.id,
      type_id: Link::BLOCK_ACCESS_SCREEN_NAME,
      asker_id: id,
      giver_id: sn.id
    )
  end

  def comments_on computer, msg do
    comment = self.computer({:msg=>msg})
    Link.create(
      owner_id: id,
      type_id:  Link::COMMENT,
      asker_id: comment.id,
      giver_id: computer.id
    )
    comment
  end

  def to_href
    "/@#{screen_name}"
  end

  #
  # Like :attach_screen_names,
  # except it also removes related screen name id
  # key. Useful for sending records to an audience.
  #
  def replace_screen_names arr do
    keys    = find_screen_name_keys(arr)
    key     = keys[0]

    new_arr = attach_screen_names arr
    new_arr.each do |r, i|
      new_arr[i][key] = nil
    end

    new_arr
  end

  def attach_screen_names arr
    keys    = find_screen_name_keys(arr)
    key     = keys[0]
    new_key = keys[1]

    vals = arr.map { |v| v[key] }
    return [] if vals.empty?

    names = TABLE[id: vals]
    map = {}
    names.each { |n| map[n[:id]] = n[:screen_name] }

    arr.each do |r, i|
      arr[i][new_key] = map[arr[i][key]]
    end

    arr
  end

  def create do
    @raw[:display_name] = @raw[:screen_name]
    clean! :screen_name
    clean :display_name, :privacy

    # === Inspired from: http://www.neilconway.org/docs/sequences/
    clean[:owner_id] = @raw[:customer] ?
      @raw[:customer].data[:id] :
      Sequel.lit("CURRVAL(PG_GET_SERIAL_SEQUENCE('#{self.class.table_name}', 'id'))")
  end # === def create

  # === UPDATE ================================================================

  def update
    clean :screen_name, :privacy, :nick_name

    if clean[:screen_name]
      clean[:display_name] = clean[:screen_name]
    end
  end # === def update do

  # === READ ==================================================================

  def owner
    @owner ||= Customer.read_by_id(data[:owner_id])
  end

  def bot cmd = nil do
    if !@bot_read
      @bot_read = true
      @bot = Bot.read_by_screen_name(self) rescue nil
    end

    return @bot.send(cmd) if cmd && @bot
    @bot
  end

  def bot_uses cmd = nil
    @bot_uses ||= begin
                    bots = Hash[ Bot.new(
                      DB[%^
                        SELECT bot.*, screen_name.screen_name as screen_name
                        FROM bot inner join screen_name
                          ON bot.id = screen_name.id
                        WHERE bot.id IN (
                          SELECT bot_id
                          FROM bot_use
                          WHERE sn_id = :sn_id AND is_on IS TRUE
                        )
                      ^, :sn_id=>id].all
                    ).map { |b| [b.id, b] } ]

                    codes = Code.new(DB[%^
                      SELECT *
                      FROM code
                      WHERE bot_id IN :ids
                    ^, :ids=>bots.keys].all)

                    codes.each { |c|
                      bots[c.bot_id].codes c
                    }

                    bots.values
                  end

    return @bot_uses unless cmd

    @bot_uses.map(&cmd)
  end # === def bot_uses do

  def read type, *args
    case type
    when :chit_chat_inbox
      Chit_Chat.read_inbox self
    else
      raise "Unknown action: #{type}"
    end
  end

  def read_bot_menu val = nil do
    sql = %^
      SELECT bot.*, screen_name.screen_name, bot_use_select.is_on
      FROM (bot Left JOIN screen_name
        ON bot.id = screen_name.id)
           LEFT JOIN ( SELECT bot_id, is_on FROM bot_use WHERE sn_id = :sn_id )
            AS bot_use_select
            ON screen_name.id = bot_use_select.bot_id
      ORDER BY screen_name ASC
    ^
    bots = Bot.new(DB[sql, :sn_id=>id].all)

    return bots unless val
    bots.map(&val)
  end

  def href sn do
    "/@#{sn.screen_name}"
  end


  def clean meta do
    if (meta.is_new) do
      var KEY = 'screen_name';

      var val = (this.new_data.screen_name || '').toString().trim().toUpperCase();

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










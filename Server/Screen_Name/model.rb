
require 'datoki'

class Screen_Name

  include Datoki

  field(:screen_name) {
    varchar 4, 30
    upcase
    matches do |r, val|
      r.fail!("Invalid screen name. #{VALID_ENGLISH}") if val !~ VALID
      r.fail!('Screen name not allowed: {{val}}') if BANNED_SCREEN_NAMES.detect { |reg| val =~ reg }
      true
    end
    unique_index 'screen_name_unique_idx', "Screen name already taken: {{val}}"
  }

  field(:display_name) {
    varchar 4, 30
    set_to { |r, val|
      r.clean[:screen_name]
    }
  }

  field(:owner_id) {
    integer
    matches do |r, v|
      v > 0
    end
  }

  # field(:class_id) {
    # smallint
    # set_to do |r, v|
      # if v < 0 || v > 2
        # 0
      # else
        # v
      # end
    # end
  # }

  field(:nick_name) {
    varchar nil, 1, 30
  }

  field(:privacy) {
    smallint 1, 3
    matches do |r, v|
      if ![1, 2, 3].include?(v)
        r.fail! "Allowed values: @W (world) @P (private) @N (no one)"
      end
      true
    end
  }
  # === Settings ========================================
  World_Read_Id   = 1
  Private_Read_Id = 2
  Not_Read_Id     = 3

  SCREEN_NAME_KEYS    = [:screen_name_id, :publisher_id, :owner_id, :author_id, :follower_id]
  BEGIN_AT_OR_HASH    = /\A(\@|\#)/
  ALL_WHITE_SPACE     = /\s+/
  VALID_CHARS         = "a-zA-Z0-9\\-\\_\\."
  VALID               = /\A[#{VALID_CHARS}]{4,20}\z/i
  VALID_ENGLISH       = "Screen name must be: 4-20 valid chars: 0-9 a-z A-Z _ - ."
  INVALID             = /[^#{VALID_CHARS}]/
  BANNED_SCREEN_NAMES = [
    /^MEGAUNI/i,
    /^MINIUNI/i,
    /^OKDOKI/i,
    /\A(ME|MINE|MY|MI|i)\z/i,
    /^PET-/i,
    /^BOT-/i,
    /^okjak/i,
    /^okjon/i,
    /^(ONLINE|CONTACT|INFO|OFFICIAL|ABOUT|NEWS|HOME)\z/i,
    /^(UNDEFINED|DEF|SEX|SEXY|XXX|TED|LARRY)\z/i,
    /^[.]+-COLA\z/i
  ]
  # =====================================================

  # === Helpers =========================================

  class << self

    def filter sn
      sn.gsub(INVALID, "")
    end

    def canonize str
      return str unless str
      return str.map {|s| canonize s } if str.is_a?(Array)

      str = str.screen_name if str.is_a?(Screen_Name)

      sn = str.strip.upcase.gsub(BEGIN_AT_OR_HASH, '').gsub(ALL_WHITE_SPACE, '-');

      if sn.index('@')
        temp = sn.split('@');
        sn = temp.pop.upcase

        while not temp.empty?
          sn = temp.pop.downcase + '@' + sn
        end
      end

      sn
    end # === def canonize_screen_name

    def delete_by_owner_ids ids
      return if ids.empty?
      TABLE.
        where(TABLE.literal [[ :owner_id, ids]]).
        delete
    end # === def delete

    def read *args
      case args.size
      when 1
        case args.first
        when Customer
          return read_list_by_customer args.first
        end
      end
      raise "Go back and correct your args."
    end

    def read_by_id id
      new TABLE.limit(1)[:id=>id], "Screen name not found."
    end

    def read_by_screen_names arr
      new TABLE.where(screen_name: Screen_Name.canonize(arr)).all
    end

    def read_by_screen_name raw_sn
      new TABLE[:screen_name=>Screen_Name.canonize(raw_sn)], "Screen name not found: #{raw_sn}"
    end

    def read_first_by_customer customer
      new TABLE.where(:owner_id=>customer.id).limit(1).first
    end

    def read_list_by_customer c
      new TABLE.where(owner_id: c.data[:id]).all
    end


  end # === class self ==================================

  # =====================================================
  # Class
  # =====================================================

  # =====================================================
  # Instance
  # =====================================================


  def to_href
    "/@#{screen_name}"
  end

  #
  # Like :attach_screen_names,
  # except it also removes related screen name id
  # key. Useful for sending records to an audience.
  #
  def replace_screen_names arr
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

  def create
    @raw[:display_name] = @raw[:screen_name]
    clean :screen_name!, :display_name, :class_id, :read_able

    # === Inspired from: http://www.neilconway.org/docs/sequences/
    clean[:owner_id] = @raw[:customer] ?
      @raw[:customer].data[:id] :
      Sequel.lit("CURRVAL(PG_GET_SERIAL_SEQUENCE('#{self.class.table_name}', 'id'))")
  end # === def create

  # === UPDATE ================================================================

  def update_privacy type
    pid = case type
          when :public
            World_Read_Id
          when :private
            Private_Read_Id
          when :no_one
            Not_Read_Id
          else
            raise "Unknown val: #{type.inspect}"
          end
    row = TABLE.returning.
      where(:id=>id).
      update(:privacy=>pid).
      first

    @data.merge!(row || {})

    self
  end

  def update
    @new_data = raw_data

    clean :screen_name, :about, :nick_name

    if clean_data[:screen_name]
      clean_data[:display_name] = clean_data[:screen_name]
    end

    row = TABLE.
      returning.
      where(:screen_name=>data[:screen_name]).
      update(clean_data).
      first

    @data.merge!(row || {})

    self
  end # === def update

  # === READ ==================================================================

  def owner
    @owner ||= Customer.read_by_id(data[:owner_id])
  end

  def bot cmd = nil
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
  end # === def bot_uses

  def read type, *args
    case type
    when :chit_chat_inbox
      Chit_Chat.read_inbox self
    else
      raise "Unknown action: #{type}"
    end
  end

  def read_bot_menu val = nil
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

  def is? o
    return true if data[:screen_name] == Screen_Name.canonize(o)
    o.is_a?(Screen_Name) && owner_id == o.owner_id
  end

  def href
    "/@#{screen_name}"
  end

  def to_public
    {
      :screen_name => screen_name,
      :href => href
    }
  end

  def owner_id
    data[:owner_id]
  end

  def screen_name
    data[:screen_name]
  end

  def find_screen_name_keys arr
    rec     = arr[0] || {:screen_name_id=>nil}
    key     = SCREEN_NAME_KEYS.detect { |k| rec.has_key? k }
    key     = key || :screen_name_id
    new_key = key.to_s.sub('_id', '_screen_name').to_sym
    [key, new_key]
  end

end # === Screen_Name ========================================












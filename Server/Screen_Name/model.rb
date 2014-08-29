
require './Server/Okdoki/model'
require './Server/Screen_Name/List'
require './Server/Okdoki/Escape_All'
require 'multi_json'

require_crud :Screen_Name

class Screen_Name

  include Okdoki::Model
  attr_reader :clean_data

  # =====================================================
  # Errors
  # =====================================================

  class Dup < Okdoki::Invalid
  end

  # =====================================================
  # Settings
  # =====================================================

  World_Read_Id   = 1
  Private_Read_Id = 2
  Not_Read_Id     = 3

  SCREEN_NAME_KEYS    = [:screen_name_id, :publisher_id, :owner_id, :author_id, :follower_id]
  BEGIN_AT_OR_HASH    = /^(\@|\#)/
  ALL_WHITE_SPACE     = /\s+/
  VALID_CHARS         = "a-zA-Z0-9\\-\\_\\."
  VALID               = /^[#{VALID_CHARS}]{4,20}$/i
  VALID_ENGLISH       = "Screen name must be: 4-20 valid chars: 0-9 a-z A-Z _ - ."
  INVALID             = /[^#{VALID_CHARS}]/
  Table_Name          = :screen_name
  TABLE               = DB[Table_Name]
  BANNED_SCREEN_NAMES = [
    /^MEGAUNI/i,
    /^MINIUNI/i,
    /^OKDOKI/i,
    /^(ME|MINE|MY|MI|i)$/i,
    /^PET-/i,
    /^BOT-/i,
    /^okjak/i,
    /^okjon/i,
    /^(ONLINE|CONTACT|INFO|OFFICIAL|ABOUT|NEWS|HOME)$/i,
    /^(UNDEFINED|DEF|SEX|SEXY|XXX|TED|LARRY)$/i,
    /^[.]+-COLA$/i
  ]

  # =====================================================
  # Helpers
  # =====================================================

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

  end # === class self ==================================

  # =====================================================
  # Class
  # =====================================================

  # =====================================================
  # Instance
  # =====================================================

  def initialize *args
    super
  end

  def to_href
    "/@#{screen_name}"
  end

  def validate *args
    case args.first
    when :screen_name
      v = super(*args).
        clean('strip', 'upcase').
        match(VALID, "Invalid: \"#{clean_data[:screen_name]}\". #{VALID_ENGLISH}")
      unless ENV['ALLOW_BANNED_SCREEN_NAME'] == 'true'
        v.not_match(BANNED_SCREEN_NAMES, 'Screen name not allowed.')
      end
      v
    when :class_id
      super(*args).
        clean('to_i').
        set_to(0, lambda { |v| v < 0 || v > 2 })
    when :about
      super(*args).set_to_nil_if_empty
    else
      super
    end
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

end # === Screen_Name ========================================












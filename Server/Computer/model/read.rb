
class Computer

  SLASH_ENDS = /\A\/|\/\Z/

  class << self # =====================

    # === Helpers =====================

    def to_event_name_id name
      EVENT_NAMES.key(name.to_s.strip.upcase) || raise(Computer::Invalid.new(new, "Unknown event name: #{name.inspect}"))
    end

    def to_event_name id
      EVENT_NAMES[Integer id] || raise(Computer::Invalid.new(new, "Unknown event name id: #{id.inspect}"))
    end

    def to_is_on val
      if val == :is_on || val == 'is_on'
        true
      else
        false
      end
    end

    # === READ methods ================

    def read_all_for_bot bot
      Computer.new(TABLE.where(bot_id: bot.id).all)
    end

    def read_by_screen_name_id_and_event_name_id id, raw_event_name_id
      new TABLE.
        where(:screen_name_id=>id, :event_name_id=>raw_event_name_id).
        limit(1).
        first
    end

    def read_by_path owner, raw_path
      path     = raw_path.downcase.gsub(SLASH_ENDS, '')
      sn       = owner.screen_name
      pieces   = path.split('/')
      possible = pieces.inject([]) { |memo, v|
        if !memo.last
          memo.push v+'/*'
        else
          memo.push "#{memo.last}/#{v}/*"
        end
        memo
      }.reverse
      possible.unshift path
      rec = DB[%^
        SELECT path, code, ss_code, 1000 AS path_size
        FROM #{Table_Name}
        WHERE owner_id = :owner_id AND path = :path

        UNION

        SELECT path, code, ss_code, char_length("path") AS path_size
        FROM #{Table_Name}
        WHERE owner_id = :owner_id AND path IN :possible

        ORDER BY "path_size" DESC
      ^, :owner_id=>owner.id, :path=> path, :possible=>possible].first
      fail Not_Found.new("#{File.join owner.screen_name, path}") unless rec
      WWW_Applet.new(rec[:code])
    end

  end # === class self ================

  def id
    data[:id]
  end

  def code
    data[:code]
  end

end # === class Computer read ===






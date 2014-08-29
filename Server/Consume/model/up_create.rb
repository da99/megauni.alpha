
class Consume

  class << self

    def up_create bot_sn, sn_id, raw_is_on
      is_on = !!raw_is_on

      update = %^
        SELECT id
        FROM screen_name
        WHERE screen_name = :bot_sn
        LIMIT 1
      ^
      insert = %^
        INSERT INTO consume (bot_id, sn_id, is_on)
          (SELECT id AS bot_id, :sn_id AS sn_id, :is_on AS is_on
          FROM   screen_name
          WHERE  screen_name = :bot_sn
          LIMIT 1)
        RETURNING *
      ^

      row = TABLE.
        returning.
        where(:sn_id=>sn_id, :bot_id=>DB[update, :bot_sn=>Screen_Name.canonize(bot_sn)]).
        update(:is_on=> is_on).
        first

      row ||= DB[insert, :bot_sn=>bot_sn, :sn_id=>sn_id, :is_on=>is_on].first

      Consume.new(row)
    end # === def up_create

  end # === class self ===

end # === class Consume up_create ===






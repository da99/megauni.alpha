
class Link

  include Datoki

  READ_SCREEN_NAME = 1
  BLOCK            = 2
  ALLOW            = 3

  field(:owner_id) {
    integer
  }

  field(:type_id) {
    smallint
  }

  field(:left_id) {
    integer
  }

  field(:right_id) {
    integer
  }

  class << self

    def read data
      case data[:type_id]
      when READ_SCREEN_NAME
        sql = <<-EOF
          SELECT screen_name.*, block.id AS block_id, allow.id AS allow_id
          FROM screen_name
             LEFT JOIN link AS block
             ON
               block.type_id = :sn_block_type_id
               AND
               block.left_id = screen_name.id
               AND
               block.right_id IN (SELECT id FROM screen_name WHERE owner_id = :audience_id) 
             LEFT JOIN link AS allow
             ON
               allow.type_id = :sn_allow_type_id
               AND
               allow.left_id = screen_name.id
               AND
               allow.right_id IN (SELECT id FROM screen_name WHERE owner_id = :audience_id)
          WHERE
            screen_name.id = :target_id
            AND (
                screen_name.privacy = :world
                OR
                (screen_name.privacy = :private AND screen_name.owner_id = :audience_id)
                OR
                (screen_name.privacy = :protected AND allow.id IS NOT NULL)
              )
            AND
            block.id IS NULL

          LIMIT 1
        EOF
        vals = {
          target_id:   data[:target_id],
          world:       Screen_Name::WORLD,
          private:     Screen_Name::PRIVATE,
          protected:   Screen_Name::PROTECTED,
          audience_id: data[:audience_id],
          sn_block_type_id: Link::BLOCK,
          sn_allow_type_id: Link::ALLOW
        }
        r = DB[Screen_Name.table_name].with_sql(sql, vals).first
        throw(:not_found, data) unless r

        r.delete :allow_id
        r.delete :block_id
        Screen_Name.new(r)
      else
        fail ArgumentError, "Unknown Link type: #{data[:type_id].inspect}"
      end
    end

  end # === class << self

  def create
    clean! :owner_id, :type_id, :left_id, :right_id
  end

end # === Link

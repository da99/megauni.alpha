
class Link

  include Datoki

  # === Link Types
  BLOCK               = 1
  ALLOW               = 2
  POST_TO_SCREEN_NAME = 3

  # === Read Types
  READ_TREE        = 10_000
  READ_SCREEN_NAME = 10
  READ_GROUP       = 11

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
               block.type_id = :LINK_BLOCK
               AND
               block.left_id = screen_name.id
               AND
               block.right_id IN (SELECT id FROM screen_name WHERE owner_id = :audience_id) 
             LEFT JOIN link AS allow
             ON
               allow.type_id = :LINK_ALLOW
               AND
               allow.left_id = screen_name.id
               AND
               allow.right_id IN (SELECT id FROM screen_name WHERE owner_id = :audience_id)
          WHERE
            screen_name.id = :SCREEN_NAME_ID
            AND (
                screen_name.privacy = :SCREEN_NAME_WORLD
                OR
                (screen_name.privacy = :SCREEN_NAME_PRIVATE AND screen_name.owner_id = :audience_id)
                OR
                (screen_name.privacy = :SCREEN_NAME_PROTECTED AND allow.id IS NOT NULL)
              )
            AND
            block.id IS NULL

          LIMIT 1
        EOF
        vals = {
          SCREEN_NAME_ID:      data[:target_id],
          SCREEN_NAME_WORLD:   Screen_Name::WORLD,
          SCREEN_NAME_PRIVATE: Screen_Name::PRIVATE,
          SCREEN_NAME_PROTECTED: Screen_Name::PROTECTED,
          audience_id:         data[:audience_id],
          LINK_BLOCK:          Link::BLOCK,
          LINK_ALLOW:          Link::ALLOW
        }

        r = DB[sql, vals].first
        throw(:not_found, data) unless r

        r.delete :allow_id
        r.delete :block_id
        Screen_Name.new(r)

      when READ_GROUP
        # === Check to see if member is allowed to view screen name:
        sn = read(:type_id=> READ_SCREEN_NAME, :audience_id=>data[:audience_id], :target_id=>data[:target_id])

        # === Read group:
        sql = <<-EOF
        SELECT *
        FROM computer
        WHERE id IN (
          SELECT right_id
          FROM link
          WHERE
            type_id = :POST_TO_SCREEN_NAME
            AND
            left_id = :SN_ID
        )
        EOF
        vals = {
          :SN_ID               => sn.id,
          :POST_TO_SCREEN_NAME => Link::POST_TO_SCREEN_NAME
        }
        r = DB[sql, vals].all
        throw(:not_found, data) if !r || r.empty?

        # === Finally, send back the computer:
        r.map { |d|
          Computer.new d
        }

      when READ_TREE
        fail %^
        This is not done. It can only handle a simple line of:
          A -> B -> C
        This is useless to most people. Instead, I have to implement:

          A.
            1.
            2.
              i.
              ii.
              iii.
            3.
         B.
           1.
           2.
            ....
               ...
               ...
                 ...
                 ...
        ^

        sql = <<-EOF
          WITH RECURSIVE links(id, oid, tid, lid, rid) AS (
             SELECT id, owner_id, type_id, left_id, right_id
             FROM link
             WHERE owner_id = 1 AND right_id = 4
          UNION
             SELECT l.id, l.owner_id, l.type_id, l.left_id, l.right_id
             FROM link l, links ls
             WHERE l.owner_id = 1 AND l.right_id = ls.lid 
          )
        EOF

        r = DB[sql, vals].all
        throw(:not_found, data) if !r || r.empty?

        # === Check to see if member is allowed to view screen name:
        read(:type_id=> READ_SCREEN_NAME, :audience_id=>data[:audience_id], :target_id=>r.first[:owner_id])

        # === Finally, send back the computer:
        Computer.new(r)

      else
        fail ArgumentError, "Unknown Link type: #{data[:type_id].inspect}"
      end
    end

  end # === class << self

  def create
    clean! :owner_id, :type_id, :left_id, :right_id
  end

end # === Link

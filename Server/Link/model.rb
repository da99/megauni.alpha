
class Link

  include Datoki

  # === Link Types
  BLOCK_ACCESS_SCREEN_NAME = 1 # meanie  -> target
  ALLOW_ACCESS_SCREEN_NAME = 2 # friend  -> target
  POST_TO_SCREEN_NAME = 3      # content -> target
  ALLOW_TO_LINK       = 4      # friend  -> target

  # === Read Types
  READ_TREE        = 10_000
  READ_SCREEN_NAME = 10
  READ_GROUP       = 11

  field(:id) {
    primary_key
  }

  field(:owner_id) {
    integer
  }

  field(:type_id) {
    smallint
  }

  field(:asker_id) {
    integer
  }

  field(:giver_id) {
    integer
  }

  class << self

    def read *args

      case args.size
      when 3
        data = {
          type_id: args.first.is_a?(Symbol) ? const_get("READ_#{args.first.to_s.upcase.sub('READ_', '')}".to_sym) : args.first,
          audience_id: args[1],
          target_id: args.last
        }
      when 1
        data = args.first
      else
        fail ArgumentError, "Unknown args: #{args.inspect}"
      end

      case data[:type_id]
      when READ_SCREEN_NAME
        sql = <<-EOF
          SELECT screen_name.*, block.id AS block_id, allow.id AS allow_id
          FROM screen_name
             LEFT JOIN link AS block
             ON
               block.type_id = :LINK_BLOCK
               AND
               block.giver_id = screen_name.id
               AND
               block.asker_id IN (SELECT id FROM screen_name WHERE owner_id = :audience_id) 
             LEFT JOIN link AS allow
             ON
               allow.type_id = :LINK_ALLOW
               AND
               allow.asker_id IN (SELECT id FROM screen_name WHERE owner_id = :audience_id)
               AND
               allow.giver_id = screen_name.id
          WHERE
            screen_name.id = :SCREEN_NAME_ID
            AND
            block.id IS NULL
            AND (
                screen_name.owner_id = :audience_id
                OR (
                  screen_name.privacy = :SCREEN_NAME_WORLD
                  OR
                  (screen_name.privacy = :SCREEN_NAME_PROTECTED AND allow.id IS NOT NULL)
                )
              )

          LIMIT 1
        EOF

        vals = {
          SCREEN_NAME_ID:      data[:target_id],
          SCREEN_NAME_WORLD:   Screen_Name::WORLD,
          SCREEN_NAME_PRIVATE: Screen_Name::PRIVATE,
          SCREEN_NAME_PROTECTED: Screen_Name::PROTECTED,
          audience_id:         data[:audience_id],
          LINK_BLOCK:          Link::BLOCK_ACCESS_SCREEN_NAME,
          LINK_ALLOW:          Link::ALLOW_ACCESS_SCREEN_NAME
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
        WHERE
        (
          privacy = :COMPUTER_WORLD
          OR
          (privacy = :COMPUTER_PRIVATE AND owner_id = :audience_id)
        )
        AND
        id IN (
          SELECT asker_id
          FROM link AS computers_to_screen_names
          WHERE
            type_id = :POST_TO_SCREEN_NAME
            AND
            giver_id = :SN_ID
            AND
            (
              owner_id IN (SELECT id FROM screen_name WHERE owner_id = :audience_id)
              OR
              owner_id = :SN_ID
              OR
              (
                owner_id IN (
                  SELECT asker_id
                  FROM link as allow
                  WHERE
                    type_id = :ALLOW_TO_LINK
                    AND
                    giver_id = :SN_ID
                )
                AND
                owner_id NOT IN (
                  SELECT asker_id
                  FROM link AS block
                  WHERE
                    type_id = :BLOCK_ACCESS_SCREEN_NAME
                    AND
                    giver_id = :SN_ID
                )
              )

            )
        )
        EOF
        vals = {
          :SN_ID                    => sn.id,
          :POST_TO_SCREEN_NAME      => Link::POST_TO_SCREEN_NAME,
          :BLOCK_ACCESS_SCREEN_NAME => Link::BLOCK_ACCESS_SCREEN_NAME,
          :ALLOW_TO_LINK            => Link::ALLOW_TO_LINK,
          :COMPUTER_WORLD           => Computer::WORLD,
          :COMPUTER_PRIVATE         => Computer::PRIVATE,
          :audience_id              => data[:audience_id]
        }

        r = DB[sql, vals].all

        throw(:not_found, data) if !r || r.empty?

        # === Finally, send back the computer:
        r.map { |d|
          Computer.new d
        }

      when READ_COMMENTS
        post = read(:type_id=>READ_POST, :target_id=>data[:target_id], :audience_id=>data[:audience_id])
        sql = <<-EOF

          SELECT *
          FROM computer
          WHERE
            id IN (
              SELECT asker_id
              FROM link AS comment_to_computer
              WHERE
                giver_id = :POST_ID
                AND
                type_id = :LINK_COMMENT
            )

        EOF

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
             SELECT id, owner_id, type_id, asker_id, giver_id
             FROM link
             WHERE owner_id = 1 AND giver_id = 4
          UNION
             SELECT l.id, l.owner_id, l.type_id, l.asker_id, l.giver_id
             FROM link l, links ls
             WHERE l.owner_id = 1 AND l.giver_id = ls.lid 
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
    clean! :owner_id, :type_id, :asker_id, :giver_id
  end

end # === Link

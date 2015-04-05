
class Link

  include Datoki

  # === Link Types
  BLOCK_ACCESS_SCREEN_NAME         = 1 # meanie  -> target
  BLOCK_ACCESS_TO_ALL_SCREEN_NAMES = 6 # meanie  -> target
  ALLOW_ACCESS_SCREEN_NAME         = 2 # friend  -> target
  POST_TO_SCREEN_NAME              = 3      # content -> target
  ALLOW_TO_LINK                    = 4      # friend  -> target
  COMMENT                          = 5      # comment -> post

  # === Read Types
  READ_TREE        = 10_000
  READ_SCREEN_NAME = 10
  READ_POST        = 12
  READ_POSTS       = 13
  READ_COMMENTS    = 14

  SQL = I_Dig_Sql.new

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

  SQL[:BLOCKS] = %^
      SELECT
        asker_id, asker_owners.owner_id AS asker_owner_id
        giver_id, giver_owners.owner_id as giver_owner_id
      FROM
        link
          LEFT JOIN screen_names AS asker_owners
          ON asker_id = asker_owners.owner_id
          LEFT JOIN screen_names AS giver_owners
          ON giver_id = giver_owners.owner_id
      WHERE
        type_id = :LINK_BLOCK
        OR
        type_id = :LINK_BLOCK_ALL_SCREEN_NAMES
  ^

  SQL[:ALLOWED_TO_POST_TO_SCREEN_NAME] = %^
      SELECT
        link.asker_id,
        screen_name.owner_id AS asker_owner_id
      FROM
        link
          LEFT JOIN screen_name
          ON asker_id = screen_name.id
      WHERE
        type_id = :LINK_ALLOW
  ^

  SQL[:AUDIENCE_ID_TO_SCREEN_NAME_IDS] = %^
      SELECT id
      FROM screen_name
      WHERE
        owner_id = :audience_id
  ^

  SQL[:AUDIENCE_ID_TO_SCREEN_NAMES] = %^
      SELECT screen_name
      FROM screen_name
      WHERE
        owner_id = :audience_id
  ^

  SQL[:SCREEN_NAME_FOR_AUDIENCE] = %^
    SELECT screen_name.id, screen_name.screen_name
    FROM screen_name
    WHERE
      screen_name = ( :SCREEN_NAME )
      AND (
        owner_id = :audience_id
        OR (
          :audience_id NOT IN ( SELECT asker_id IN {{RAW_BLOCKS}} WHERE giver_id = (<< SCREEN_NAME_TO_ID >>) AND asker_id NOT IN ( << AUDIENCE_ID_TO_SCREEN_NAME_IDS >> ))
          AND (
            privacy = :SCREEN_NAME_WORLD
            OR (
              privacy = :SCREEN_NAME_PROTECTED
              AND
              :audience_id IN ( << ALLOWED >> )
            )
          )
        )
      )
  ^

  SQL[:SCREEN_NAME_ID] = %^
    SELECT id
    FROM {{SCREEN_NAME_FOR_AUDIENCE}}
  ^

  SQL[:POSTS] = %^
    -- Unfiltered, COMPUTERS LINKed to SCREEN_NAME
    --   as POST
    SELECT
      computer.id               AS computer_id,
      computer.owner_id         AS computer_owner_id,
      computer.code             AS computer_code,
      computer.created_at       AS computer_created_at,
      computer.updated_at       AS computer_updated_at,

      post_link.owner_id             AS post_author_id,
      post_link.giver_id             AS post_target_id,

      owner_post_link.owner_id       AS post_owner_id
    FROM computer

      INNER JOIN link AS post_link
      ON
        post_link.type_id = :LINK_POST_TO_SCREEN_NAME
        AND
        computer.id = post_link.asker_id
        AND
        post_link.giver_id = (<<SCREEN_NAME_TO_ID>>)

      LEFT JOIN screen_name AS owner_post_link
      ON
        post_link.owner_id = owner_post_link.owner_id

    WHERE
      post_target_id = (<< SCREEN_NAME_ID >>)

      AND ( -- ALLOWED owner
        post_owner_id = :AUDIENCE_ID
        OR
        post_owner_id = (<<SCREEN_NAME_TO_ID>>)

        OR ( -- Mutual BLOCKS:
          post_owner_id NOT IN (
            SELECT blocked_owner_id
            FROM {{ALL_BLOCKED_IDS}}
            WHERE
              giver_owner_id = (<<OWNER_ID_OF_SCREEN_NAME>>)
              OR
              giver_owner_id = :AUDIENCE_ID
          )
          AND
          post_owner_id NOT IN (
            SELECT giver_owner_id
            FROM {{ALL_BLOCKED_IDS}}
            WHERE
              blocked_owner_id = (<<OWNER_ID_OF_SCREEN_NAME>>)
              OR
              blocked_owner_id = :AUDIENCE_ID
          )
        ) -- # Mutual BLOCKS

      ) -- # ALLOWED owner

      AND (
        computer.privacy = :COMPUTER_WORLD
        OR (
          computer.privacy = :COMPUTER_PROTECTED
          AND
          ( post_owner_id = :AUDIENCE_ID OR post_owner_id = (<<OWNER_ID_OF_SCREEN_NAME>>) )
        )
        OR (
          computer.privacy = :COMPUTER_PRIVATE
          AND
          post_owner_id = :AUDIENCE_ID
        )
      )
  ^

  SQL[:COMMENTS] = %^
    SELECT
      computer.id         AS comment_id,
      computer.code       AS comment_code,
      computer.created_at AS comment_created_at,
      computer.updated_at AS comment_updated_at,

      owner_comment_link.owner_id AS comment_owner_id

    FROM

      computer INNER JOIN link AS comment_link
      ON computer.id = comment_link.asker_id
         AND
         comment_link.type_id = :LINK_COMMENT
         AND
         comment_link.giver_id = (<< computer_id POSTS>> WHERE computer_id = :POST_ID)

      LEFT JOIN screen_name owner_comment_link
      ON comment_link.owner_id = screen_name.owner_id


    WHERE
      ( -- ALLOWED OWNER
        comment_owner_id = :AUDIENCE_ID

        OR
        comment_owner_id = :SCREEN_NAME_TO_ID

        OR ( -- mutual BLOCKS
          comment_owner_id NOT IN  (
            SELECT blocked_owner_id
            FROM {{ALL_BLOCKED_IDS}}
            WHERE
              giver_owner_id = (<<OWNER_ID_OF_SCREEN_NAME>>)
              OR
              giver_owner_id = :AUDIENCE_ID
          )
          AND
          comment_owner_id NOT IN (
            SELECT giver_owner_id
            FROM {{ALL_BLOCKED_IDS}}
            WHERE
              blocked_owner_id = (<<OWNER_ID_OF_SCREEN_NAME>>)
              OR
              blocked_owner_id = :AUDIENCE_ID
          )
        ) -- # mutual BLOCKS
      ) -- # ALLOWED OWNER
      AND (
        computer.privacy = :COMPUTER_WORLD
        OR (
          computer.privacy = :COMPUTER_PRIVATE
          AND
          comment_owner_id = :AUDIENCE_ID
        )
        OR (
          computer.privacy = :PROTECTED
          AND (
            comment_owner_id = :AUDIENCE_ID
            OR
            :AUDIENCE_ID = (<<OWNER_ID_OF_SCREEN_NAME>>)
            OR
            :AUDIENCE_ID = (<<post_owner_id POSTS>>)
          )
        )
      )
  ^


  SQL.vars[:SCREEN_NAME_WORLD]     = Screen_Name::WORLD
  SQL.vars[:SCREEN_NAME_PRIVATE]   = Screen_Name::PRIVATE
  SQL.vars[:SCREEN_NAME_PROTECTED] = Screen_Name::PROTECTED

  SQL.vars[:COMPUTER_WORLD]   = Computer::WORLD
  SQL.vars[:COMPUTER_PRIVATE] = Computer::PRIVATE

  SQL.vars[:LINK_BLOCK]                  = Link::BLOCK_ACCESS_SCREEN_NAME
  SQL.vars[:LINK_BLOCK_ALL_SCREEN_NAMES] = Link::BLOCK_ACCESS_TO_ALL_SCREEN_NAMES
  SQL.vars[:LINK_ALLOW]                  = Link::ALLOW_ACCESS_SCREEN_NAME
  SQL.vars[:LINK_POST_TO_SCREEN_NAME]    = Link::POST_TO_SCREEN_NAME
  SQL.vars[:ALLOW_TO_LINK]               = Link::ALLOW_TO_LINK

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
        i = I_Dig_Sql.new( SQL, <<-EOF )
          << SCREEN_NAME >>
        EOF
        i.vars[:screen_name] = data[:target_id]
        i.vars[:audience_id] = data[:audience_id]

        r = DB[i.to_sql, i.vars].first
        throw(:not_found, {:type=>:SCREEN_NAME, :id=>data[:target_id]}) unless r

        r.delete :allow_id
        r.delete :block_id
        Screen_Name.new(r)

      when READ_POSTS
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

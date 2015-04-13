
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

  SQL[:block] = %^
    SELECT
      block.type_id       AS type_id,
      blocked.screen_name AS blocked_screen_name,
      blocked.id          AS blocked_id,
      blocked.owner_id    AS blocked_owner_id,

      victim.screen_name AS victim_screen_name,
      victim.id          AS victim_id,
      victim.owner_id    AS victim_owner_id
    FROM
      link AS block
      LEFT JOIN screen_name AS blocked
        ON asker_id = blocked_screen_name.id
      LEFT JOIN screen_name AS victim
        ON giver_id = victim.id
    WHERE
      type_id = :BLOCK_SCREEN_NAME_TYPE_ID
      OR
      type_id = :BLOCK_OWNER_TYPE_ID
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

  SQL[:privacy?] = lambda { |dig, *args|
    "-- NOT READY: privacy ----"
  }

  SQL[:permit_screen_name?] = lambda { |dig, bad, good|
    %^(
            block.type_id          = :BLOCK_SCREEN_TYPE_ID
            AND
            block.blocked_owner_id = #{bad}.owner_id
            AND
            block.victim_id        = #{good}.id
          )^
  }

  SQL[:permit_owner?] = lambda { |dig, bad, good|
    %^(
            block.type_id          = :BLOCK_OWNER_TYPE_ID
            AND
            block.blocked_owner_id = #{bad}.owner_id
            AND
            block.victim_owner_id  = #{good}.owner_id

            AND (
              #{good}.privacy = :WORLD
              OR (
                #{good}.privacy = :PROTECTED
                AND (
                  #{bad}.owner_id = #{good}.owner_id
                  OR
                  #{bad}.owner_id IN (
                    SELECT {{allowed}}.allowed_owner_id
                    FROM {{allowed}}
                    WHERE {{allowed}}.owner_id = #{good}.owner_id
                  )
                )
              )
            ) -- AND both have the right privacy settings
          )
    ^
  }

  SQL[:link_screen_names] = lambda { |dig, *args|
    left, right, comp = args.map(&:to_sym)
    if comp
      return(
      %^
        link.owner_id = #{left}.id
        AND
        link.asker_id = computer.id
        AND
        computer.owner_id = author.id
        AND
        link.giver_id = #{right}.id
      ^
      )
    end

    %^
      link.asker_id = #{left}.id
      AND
      link.giver_id = #{right}.id
    ^
  }

  SQL[:computer_privacy] = lambda { |dig|
    %^(
        computer.privacy = :COMPUTER_WORLD
        OR
        computer.privacy = :COMPUTER_INHERIT
        OR (
          computer.privacy = :COMPUTER_PROTECTED
          AND
          (
            :AUDIENCE_ID IS IN ALLOWED_LIST
            OR
            author.owner_id = :AUDIENCE_ID
          )
        )
        OR (
          computer.privacy = :COMPUTER_PRIVATE
          AND
          author.owner_id = :AUDIENCE_ID
        )
      ) -- computer privacy
    ^
  }

  SQL[:permit?] = lambda { |dig, *args|

    bad, good, comp = args.map(&:to_sym)

    if comp
      return <<-EOF
      << permit? #{bad} #{good} >>
      AND
      << permit? #{bad} author >>
      AND
      << permit? #{good} author >>
      AND
      << computer_privacy >>
      EOF
    end

    %^
      NOT EXISTS (
        SELECT 1
        FROM {{block}}
        WHERE
          << permit_screen_name? #{bad} #{good} >>
          OR
          << permit_screen_name? #{good} #{bad} >>
          OR
          << permit_owner? #{good} #{bad} >>
          OR
          << permit_owner? #{bad} #{good} >>
      ) -- NOT EXISTS
    ^
  } # === lambda

  SQL[:post] = <<-EOF
    -- POST
    SELECT
      computer.id               AS id,
      computer.owner_id         AS author_owner_id,
      computer.code             AS code,
      computer.created_at       AS created_at,
      computer.updated_at       AS updated_at,

      link.owner_id             AS post_author_id,
      pub.id                    AS pub_id,
      pub.screen_name           AS pub_name,
      pub.owner_id              AS pub_owner_id

    FROM

      link,
      screen_name AS pinner,
      screen_name AS pub,
      computer    AS post,
      screen_name AS author

    WHERE
      link.type_id = :POST_TYPE_ID

      AND
      << link_screen_names pinner pub post >>

      AND
      << read_computer? pinner pub computer >>

    ORDER BY created_at DESC
  EOF

  SQL[:COMMENTS] = %^
    SELECT
      computer.id         AS comment_id,
      computer.code       AS comment_code,
      computer.created_at AS comment_created_at,
      computer.updated_at AS comment_updated_at,

      owner_comment_link.owner_id AS comment_owner_id

    FROM

      post,
      link,
      computer    AS comment,
      screen_name AS author


    WHERE

      post.id = :POST_ID
      AND link.type_id  = :COMMENT_TYPE_ID
      AND link.owner_id = author.id
      AND link.asker_id = computer.id
      AND link.giver_id = post.computer_id

      AND
      << read? author post.pub_owner_id >>

      AND
      << read_computer? author post.id >>

      AND
      << read_computer? :AUDIENCE_ID comment >>


      AND ( -- PRIVACY
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
      ) -- # PRIVACY
  ^

  SQL[:FOLLOWS_by_audience] = %^

join authentic follows
to contribs

    SELECT fields
      audience.owner_id AS asker_id
    FROM
      link AS follow

      INNER JOIN screen_name AS audience
      ON follow.asker_id = audience.id
         AND DOES NOT BLOCK target
         AND DOES NOT BLOCK owner

      INNER JOIN screen_name AS target
      ON follow.giver_id = target.id
         AND DOES NOT BLOCK aud
         AND DOES NOT BLOCK owner
         AND WHEN PRIVACY PRIVATE
         AND WHEN PRIVACY PROTECTED

    WHERE
      follow.type_id = :LINK_FEED
      AND
      follow.asker_id

  ^

  SQL[:FEED] = %^
    SELECT
      target.screen_name AS feed_name

    FROM
      link AS feed_link,
      link AS post_link,
      screen_name AS audience,
      screen_name AS target,
      screen_name AS poster




      ON post_link.giver_id = feed_link.giver_id
         AND
         post_link.type_id = :LINK_POST_TO_SCREEN_NAME
         AND
         feed_link.type_id = :LINK_FEED

      INNER JOIN 
      ON audience.id = feed_link.owner_id
         AND
         audience.owner_id = :AUDIENCE_ID

      LEFT JOIN 
      ON post.id = post_link.asker_id

      LEFT JOIN link AS blocks_by_target
      ON blocks_by_target.giver_id = feed_link.giver_id
      LEFT JOIN link AS blocks_by_post_link_owner
      ON blocks_by_post_link_owner.giver_id = 

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

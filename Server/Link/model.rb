
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

  module Helpers
    names = [:owner_id, :privacy, :id, :screen_name_id, :author_owner_id]

    refine String do
      def to_field_name name
        "#{self}_#{name}"
      end
    end

    refine Symbol do
      def to_field_name name
        if self == :AUDIENCE_ID
          self
        else
          "#{self}.#{name}"
        end
      end
    end

    [Symbol, String].each { |c|
      refine c do
        names.each { |n|
          eval <<-EOF, nil, __FILE__, __LINE__+1
            def #{n}
              to_field_name(:#{n})
            end
          EOF
        }
      end
    }
  end # === module Helpers

  class << self

    using Helpers

    def allow_user? left, computer
      "
        ( -- Is #{left.inspect} allowed to see computer: #{computer.inspect} ?
          #{left.owner_id} = #{computer.owner_id}
          OR
          #{computer.privacy} = :COMPUTER_WORLD
        )
      "
    end

    def allow_read? left, right
      "
        ( -- Is #{left.inspect} allowed to read #{right.inspect}?
          #{left.owner_id} = #{right.owner_id}  -- is left/right the author?
          OR
          #{right.privacy} = :WORLD
          OR
          (
            #{right.privacy} = :PROTECTED
            AND
            EXISTS ( -- is left on \"the list\"?
              SELECT 1
              FROM  {{allowed_reader}}
              WHERE {{allowed_reader}}.pub    = #{right.screen_name_id}
                AND {{allowed_reader}}.reader = #{left.screen_name_id}
            ) -- EXISTS
          ) -- OR
        ) -- allow_read?
      "
    end

    def readers? *people
      computers = people.last.is_a?(Array) && people.pop
      conds = []

      people.each { |left|
        people.each { |right|

          next if left == right

          # === If bth are strings, that means they were taken care of
          # in an other CTE.
          next if left.is_a?(String) && right.is_a?(String)

          conds << allow_read?(left, right)

        }

        computers.each { |comp|
          next if left.is_a?(String) && comp.is_a?(String)
          conds << allow_user?(left, comp)
        }
      }

      conds.compact.join "  AND   "
    end

    def talker? *args
      "talker? NOT READY"
    end

    def poster? *args
      "poster? not ready"
    end

  end # === class

  SQL[:allowed_reader] = %^
    SELECT
      reader.id       AS reader_screen_name_id,
      reader.owner_id AS reader_owner_id,
      reader.privacy  AS reader_privacy,

      pub.id          AS pub_screen_name_id,
      pub.owner_id    AS pub_owner_id,
      pub.privacy     AS pub_privacy

    FROM
      link AS allowed_reader,
      screen_name AS reader,
      screen_name AS pub

    WHERE
      allowed_reader.asker_id = reader.id
      AND
      allowed_reader.type_id = :ALLOW_TO_READ_TYPE_ID
      AND
      allowed_reader.giver_id = pub.id
  ^

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
    <<-EOF
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
    EOF
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

  SQL[:read_able_computer?] = lambda { |dig, person, computer|

    %^(
        #{computer.privacy} = :COMPUTER_WORLD
        OR
        #{computer.privacy} = :COMPUTER_INHERIT
        OR (
          #{computer.privacy} = :COMPUTER_PROTECTED
          AND
          (
            #{person.owner_id} = :AUDIENCE_ID
          )
        )
        OR (
          #{computer.privacy} = :COMPUTER_PRIVATE
          AND
          #{computer.author_owner_id} = :AUDIENCE_ID
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
      computer.id               AS post_id,
      computer.owner_id         AS post_author_owner_id,
      computer.code             AS post_code,

      link.created_at           AS post_posted_at

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
          link.type_id  = :POST_TYPE_ID
      AND link.owner_id = pinner.id AND link.owner_id = post.owner_id
      AND link.asker_id = post.id
      AND link.giver_id = pub.id
      AND post.owner_id = author.id

      AND ( PINNER IS ALLOWED NOT BLOCKED TO POST )
      AND ( AUTHOR IS ALLOWED NOT BLOCKED BY PINNER, PUB )
      AND ( :AUDIENCE_OWNER_ID (IS ALLOWED) AND (NOT BLOCKED) PINNER, PUB, AUTHOR )
      AND ( COMPUTER PRIVACY SETTINGS for PINNER, PUB, :AUDIENCE_OWNER_ID )

    ORDER BY created_at DESC
  EOF

  SQL[:comment] = %^
    SELECT
      computer.id                 AS comment_id,
      computer.code               AS comment_code,
      computer.created_at         AS comment_created_at,
      computer.updated_at         AS comment_updated_at,

      owner_comment_link.owner_id AS comment_owner_id

    FROM

      post,
      link,
      computer    AS comment,
      screen_name AS talker


    WHERE

      -- SET UP THE FULL TABLE -----------------
      post.id = :POST_ID
      AND link.type_id  = :COMMENT_TYPE_ID
      AND link.owner_id = talker.id AND link.owner_id = comment.owner_id
      AND link.asker_id = comment.id
      AND link.giver_id = post.computer_id
      -- ---------------------------------------

      AND
      #{ readers? 'post.pub' , 'post.pinner', :talker, ['post.computer', :comment] }
      AND
      #{ talker?  :talker, :comment }

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

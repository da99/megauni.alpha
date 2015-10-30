

-- "I want to post content to my screen name:"
  --  owner_id -> a          ->  b
  --  sn_id    |  card_id    |   sn_id


-- "Last time I read this"
  -- owner_id   -> a         ->  b
  -- user_id    |  user_id   |   sn_id (publication)

CREATE TABLE link (

  id          serial            NOT NULL PRIMARY KEY,
  owner_id    integer           NOT NULL,
  type_id     smallint          NOT NULL,
  a_id        integer           NOT NULL,
  b_id        integer           NOT NULL,

  created_at        timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  updated_at        timestamp with time zone,

  CONSTRAINT  "link_unique_idx"
    UNIQUE (owner_id, type_id, a_id, b_id)

); -- CREATE TABLE link

-- DOWN

DROP TABLE IF EXISTS link CASCADE;




-- DOWN

DROP TABLE IF EXISTS link CASCADE;

-- UP

-- "I want to post content to my screen name:"
  --  owner_id -> a          ->  b
  --  sn_id    |  card_id    |   sn_id
-- "Last time I read this"
  -- owner_id   -> a         ->  b
  -- user_id    |  user_id   |   sn_id (publication)
CREATE TABLE IF NOT EXISTS link (

  id            INT               NOT NULL AUTO_INCREMENT PRIMARY KEY,
  type_id       smallint          NOT NULL,

  owner_id      integer           NOT NULL,
  owner_type_id smallint          NOT NULL,

  a_id          integer           NOT NULL,
  a_type_id     smallint          NOT NULL,

  b_id          integer           NOT NULL,
  b_type_id     smallint          NOT NULL,

  created_at        timestamp,
  updated_at        timestamp     NULL,

  CONSTRAINT  `link_unique_idx`
    UNIQUE (
      type_id,
      owner_id,  owner_type_id,
      a_id,      a_type_id,
      b_id,      b_type_id
    )

) engine=TokuDB; -- CREATE TABLE link


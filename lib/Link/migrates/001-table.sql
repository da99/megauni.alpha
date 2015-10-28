
-- LINK_TYPE_ID = 1
  --  BLOCK_ACCESS_SCREEN_NAME         = 10 # meanie  -> me
  --  BLOCK_ACCESS_TO_ALL_SCREEN_NAMES = 11 # meanie  -> me
  --  ALLOW_ACCESS_SCREEN_NAME         = 12 # friend  -> me

  --  link CARD to SN                  = 20     # sn_id, card.id -> sn.id
  --  ALLOW_TO_LINK                    = 21     # friend  -> target
  --  LAST READ AT                     = 22     # owner_id -> owner_id => sn.id
  --  follow                           = 23     # sn, sn -> target
  --  ALLOW TO READ CARD               = 24     # sn, sn -> card.id

  --  COMMENT                          = 30     # comment -> post

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


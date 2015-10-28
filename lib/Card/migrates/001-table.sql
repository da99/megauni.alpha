
CREATE TABLE card (

  id                SERIAL                PRIMARY KEY,

  -- owner_id:
  -- Refers to screen_name id:
  owner_id          integer               NOT NULL,

  -- privacy:
  -- 1: me_only
  -- 2: same as SN
  -- 3: list of card, ignoring SN list
  -- 4: world readable bypassing screen_name
  privacy        SMALLINT                 NOT NULL DEFAULT 1,

  code           JSONB                    NOT NULL,

  created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT timezone('UTC'::text, now()),
  updated_at     TIMESTAMP WITH TIME ZONE

);


-- DOWN


DROP TABLE IF EXISTS card CASCADE;


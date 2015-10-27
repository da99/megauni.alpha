
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
  privacy           smallint              NOT NULL DEFAULT 1,

  code              jsonb                 NOT NULL,

  created_at     timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  updated_at     timestamp with time zone

);


-- DOWN


DROP TABLE IF EXISTS card CASCADE;


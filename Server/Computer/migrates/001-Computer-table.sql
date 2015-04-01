
CREATE TABLE computer (

  id                SERIAL                PRIMARY KEY,
  owner_id          integer               NOT NULL,
  privacy           smallint              NOT NULL DEFAULT 3,
  code              jsonb                 NOT NULL,

  created_at     timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  updated_at     timestamp with time zone

);


-- DOWN


DROP TABLE IF EXISTS computer CASCADE;






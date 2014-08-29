
CREATE TABLE computer (

  id                SERIAL                PRIMARY KEY,
  owner_id          integer               NOT NULL,

  path              varchar(111)          NOT NULL,

  title             varchar(99)           DEFAULT NULL,
  code              text                  DEFAULT NULL,
  ss_code           text                  DEFAULT NULL,

  created_at     timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  updated_at     timestamp with time zone,

  CONSTRAINT "computer_unique_idx"
    UNIQUE (owner_id, path)

);


-- DOWN


DROP TABLE IF EXISTS computer CASCADE;






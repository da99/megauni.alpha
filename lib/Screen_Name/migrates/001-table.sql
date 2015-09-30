
CREATE TABLE screen_name (

  -- Primary key:
  id             serial   NOT NULL,
  CONSTRAINT     "screen_name_pkey" PRIMARY KEY (id),

  -- Refers to "user" id:
  owner_id       integer  NOT NULL,

  -- privacy:
  privacy        smallint NOT NULL DEFAULT 1,

  -- Refers to "screen_name" id. 0 == top level:
  parent_id      integer  NOT NULL DEFAULT 0,

  -- screen_name:
  screen_name    character varying(30)    NOT NULL,
  CONSTRAINT     "screen_name_unique_idx" UNIQUE (parent_id, screen_name),

  -- nick_name:
  nick_name      character varying(30)   DEFAULT NULL,

  -- dates:
  created_at     timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  trashed_at     timestamp with time zone

);

CREATE OR REPLACE FUNCTION screen_name_insert(
  IN  raw_owner_id INT,
  IN  raw_screen_name VARCHAR,
  OUT owner_id INT,
  OUT screen_name VARCHAR
)
AS $$
  DECLARE
    sn_record RECORD;
  BEGIN

    raw_screen_name := screen_name_canonize(raw_screen_name);

    IF char_length(raw_screen_name) > 30 THEN
      RAISE EXCEPTION 'screen_name: max 30';
    END IF;

    INSERT INTO screen_name (owner_id, screen_name)
    VALUES (raw_owner_id, raw_screen_name)
    RETURNING "screen_name".owner_id, "screen_name".screen_name
    INTO sn_record;

    owner_id    := sn_record.owner_id;
    screen_name := sn_record.screen_name;
  END
$$ LANGUAGE plpgsql;

-- DOWN


DROP FUNCTION screen_name_insert ( INT, VARCHAR ) CASCADE;

DROP TABLE screen_name CASCADE;

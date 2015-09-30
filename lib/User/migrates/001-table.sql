
CREATE TABLE "user" (
  id                   serial PRIMARY KEY,
  pswd_hash            bytea        NOT NULL,
  created_at           timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  trashed_at           timestamp with time zone
);

CREATE OR REPLACE FUNCTION user_insert(
  IN  sn_name     varchar,
  IN  pswd_hash   bytea,
  OUT id          int,
  OUT screen_name text
)
AS $$
  DECLARE
    sn_record RECORD;
  BEGIN
    IF pswd_hash IS NULL THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash not set';
    END IF;

    IF length(pswd_hash) < 10 THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash';
    END IF;

    INSERT INTO screen_name (screen_name)
    VALUES (sn_name)
    RETURNING owner_id, "screen_name".screen_name
    INTO sn_record;

    INSERT INTO
    "user" ( id,                 pswd_hash )
    VALUES ( sn_record.owner_id, pswd_hash );

    id          := sn_record.owner_id;
    screen_name := sn_record.screen_name;
  END
$$ LANGUAGE plpgsql;


-- DOWN


DROP FUNCTION user_insert ( varchar, bytea ) CASCADE;
DROP TABLE    "user"                         CASCADE;


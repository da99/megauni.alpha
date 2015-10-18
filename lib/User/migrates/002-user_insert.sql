
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

    SELECT *
    INTO sn_record
    FROM screen_name_insert(null, sn_name)
    ;

    INSERT INTO
    "user" ( id,                 pswd_hash )
    VALUES ( sn_record.owner_id, pswd_hash )
    ;

    id          := sn_record.owner_id;
    screen_name := sn_record.screen_name;
  END
$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION user_insert ( varchar, bytea ) CASCADE;


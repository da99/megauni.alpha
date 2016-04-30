
-- DOWN
SELECT drop_megauni_func('user_insert');

-- UP

--  Use "user_insert" instead of "insert"
--  because:
--    * "insert" won't accept a non-column
--     value, like sn_name.
--    * Also, "user_insert" creates a Screen_Name and User.
CREATE OR REPLACE FUNCTION user_insert(
  IN  sn_name     varchar,
  IN  pswd_hash   varchar,
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
    VALUES ( sn_record.owner_id, pswd_hash::BYTEA )
    ;

    id          := sn_record.owner_id;
    screen_name := sn_record.screen_name;
  END
$$ LANGUAGE plpgsql;



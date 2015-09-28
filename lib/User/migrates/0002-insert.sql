
CREATE OR REPLACE FUNCTION user_insert(
  IN  sn_name VARCHAR,
  IN  pswd_hash   bytea,
  OUT id          int,
  OUT screen_name text
)
AS $$
  DECLARE
    sn    RECORD;
    u     RECORD;
    --  final RECORD;
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
    INTO sn;

    INSERT INTO "user" (id, pswd_hash)
    VALUES ( sn.owner_id, pswd_hash )
    RETURNING "user".id
    INTO u;

    screen_name := sn.screen_name;
    id          := sn.owner_id;
    --  final.screen_name := sn.screen_name;
    --  final.id          := u.id;
    --  RETURN final;
  END
$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION IF EXISTS user_insert (
  VARCHAR,
  bytea,
  int,
  text
)
  CASCADE;



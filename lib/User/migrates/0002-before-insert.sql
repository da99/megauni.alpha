
CREATE OR REPLACE FUNCTION user_before_insert()
RETURNS trigger AS $$
  DECLARE
    final user%ROWTYPE;
    sn    screen_name%ROWTYPE;
  BEGIN
    IF NEW.pswd_hash IS NULL THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash not set';
    END IF;

    IF char_length(NEW.pswd_hash) < 10 THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash';
    END IF;

    INSERT INTO screen_name (screen_name)
    VALUES (NEW.screen_name)
    RETURNING owner_id, screen_name
    INTO sn;

    final.id        := sn.owner_id;
    final.pswd_hash := NEW.pswd_hash;
    RETURN final;
  END
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean
  BEFORE INSERT OR UPDATE ON "user"
  FOR EACH ROW EXECUTE PROCEDURE user_before_insert();

-- DOWN

DROP TRIGGER IF EXISTS clean
  ON "user"
  CASCADE;

DROP FUNCTION IF EXISTS user_before_insert ()
  CASCADE;



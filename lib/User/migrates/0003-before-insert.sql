
CREATE OR REPLACE FUNCTION user_before_insert()
RETURNS trigger AS $$
  DECLARE
    final user%ROWTYPE;
    --  sn    screen_name%ROWTYPE;
  BEGIN

    --  INSERT INTO screen_name (screen_name)
    --  VALUES (NEW.screen_name)
    --  RETURNING *
    --  INTO sn;

    final.id        := 1;
    final.pswd_hash := NEW.pswd_hash;
    RETURN final;
  END
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean
  BEFORE INSERT ON "user"
  FOR EACH STATEMENT
  EXECUTE PROCEDURE user_before_insert();

-- DOWN

DROP TRIGGER IF EXISTS clean
  ON "user"
  CASCADE;

DROP FUNCTION IF EXISTS user_before_insert ()
  CASCADE;

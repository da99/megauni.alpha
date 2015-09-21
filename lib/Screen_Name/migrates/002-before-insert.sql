
-- For tips on triggers:
-- http://hsqldb.org/doc/guide/triggers-chapt.html

CREATE FUNCTION screen_name_before_insert()
RETURNS trigger AS $$
  BEGIN
    -- screen_name
    NEW.screen_name := upper(NEW.screen_name);

    -- owner_id
    IF NEW.owner_id IS NULL THEN
      -- Inspired from: http://www.neilconway.org/docs/sequences/
      NEW.owner_id := CURRVAL(PG_GET_SERIAL_SEQUENCE( 'screen_name', 'id' ));
    END IF;

    -- nick_name
    IF NEW.nick_name IS NOT NULL THEN
      NEW.nick_name := regexp_replace(NEW.nick_name, '[[:cntrl:]]+', ' ');
      NEW.nick_name := regexp_replace(NEW.nick_name, '[\s]+', ' ');
      NEW.nick_name := trim(both ' ' from NEW.nick_name);

      IF NEW.nick_name == '' THEN
        NEW.nick_name := NULL;
      END IF;
    END IF;

    RETURN NEW;
  END
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean
  BEFORE INSERT OR UPDATE ON screen_name
  FOR EACH ROW EXECUTE PROCEDURE screen_name_before_insert();
-- DOWN

DROP TRIGGER IF EXISTS clean
  ON screen_name
  CASCADE;

DROP FUNCTION IF EXISTS screen_name_before_insert ()
  CASCADE;



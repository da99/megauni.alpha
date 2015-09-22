
-- For tips on triggers:
-- http://hsqldb.org/doc/guide/triggers-chapt.html

CREATE OR REPLACE FUNCTION screen_name_before_insert()
RETURNS trigger AS $$
  BEGIN

    -- privacy
    IF NEW.privacy < 1 OR NEW.privacy > 3 THEN
      RAISE EXCEPTION 'programmer_error: privacy must be in [1-ME_ONLY,2-ON_LIST,3-PUBLIC]';
    END IF;

    -- screen_name
    NEW.screen_name := screen_name_canonize(NEW.screen_name);

    IF char_length(NEW.screen_name) < 4 THEN
      RAISE EXCEPTION 'screen_name_min: 4';
    END IF;

    IF char_length(NEW.screen_name) > 30 THEN
      RAISE EXCEPTION 'screen_name_max: 30';
    END IF;

    IF NEW.screen_name !~ '^[A-Z\d\-\_\.]+$' THEN
      raise EXCEPTION 'screen_name_valid_chars: numbers, letters, underscores, dash, or periods.';
    END IF;

    -- Banned screen names:
    IF NEW.screen_name !~* '[^A-Z](MEGAUNI|MINIUNI|OKDOKI|BOT-|okjak|okjon)' OR
       NEW.screen_name !~* '^(ME|MINE|MY|MI|[.]+-COLA|UNDEFINED|DEF|SEX|SEXY|XXX|TED|LARRY|ONLINE|CONTACT|INFO|OFFICIAL|ABOUT|NEWS|HOME)$'
    THEN
      RAISE EXCEPTION 'screen_name_not_available: Screen name not available.';
    END IF;

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



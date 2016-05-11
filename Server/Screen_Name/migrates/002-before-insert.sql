
-- DOWN

DROP TRIGGER IF EXISTS clean
  ON screen_name
  CASCADE;

DROP FUNCTION IF EXISTS screen_name_before_insert ()
  CASCADE;



-- UP
-- For tips on triggers:
-- http://hsqldb.org/doc/guide/triggers-chapt.html

CREATE OR REPLACE FUNCTION screen_name_before_insert()
RETURNS trigger AS $$
  DECLARE
    allowed_privacy CONSTANT varchar := 'ME ONLY, LIST ONLY, WORLD READABLE';
  BEGIN

    -- privacy
    IF NOT ( NEW.privacy = ANY(names_to_type_id_array(allowed_privacy)) ) THEN
      RAISE EXCEPTION 'programmer_error: privacy must be: %', allowed_privacy;
    END IF;

    -- screen_name
    NEW.screen_name := screen_name_canonize(NEW.screen_name);

    IF char_length(NEW.screen_name) > 30 THEN
      RAISE EXCEPTION 'user_error: screen_name: max 30';
    END IF;

    IF char_length(NEW.screen_name) < 4 THEN
      RAISE EXCEPTION 'user_error: screen_name: min 4';
    END IF;

    IF NEW.screen_name !~ '^[A-Z\d\-\_\.]+$' THEN
      raise EXCEPTION 'user_error: screen_name: invalid_chars %', regexp_replace(NEW.screen_name, '[A-Z\d\-\_\.]+', '', 'ig');
    END IF;

    -- Banned screen names:
    IF NEW.screen_name ~* '(SCREEN[\_\.\-\+]+NAME|MEGAUNI|MINIUNI|OKDOKI|okjak|okjon)' OR
       NEW.screen_name ~* '^(BOT-|ME|MINE|MY|MI|[.]+-COLA|UNDEFINED|DEF|SEX|SEXY|XXX|TED|LARRY|ONLINE|CONTACT|INFO|OFFICIAL|ABOUT|NEWS|HOME)$'
    THEN
      RAISE EXCEPTION 'user_error: screen_name: not_available';
    END IF;

    -- owner_id
    IF NEW.owner_id IS NULL THEN
      -- Inspired from: http://www.neilconway.org/docs/sequences/
      NEW.owner_id := CURRVAL(PG_GET_SERIAL_SEQUENCE( 'screen_name', 'id' ));
    END IF;

    -- nick_name
    IF NEW.nick_name IS NOT NULL THEN
      -- Replace all control chars into spaces:
      NEW.nick_name := regexp_replace(NEW.nick_name, '[[:cntrl:]]+', ' ', 'ig');
      -- Replace all multiple spaces into single space:
      NEW.nick_name := regexp_replace(NEW.nick_name, '[\s]+',        ' ', 'ig');
      -- Trim both sides:
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



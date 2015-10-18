


CREATE FUNCTION screen_name_insert(
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



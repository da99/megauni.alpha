
CREATE FUNCTION screen_name_read(
  IN  raw_screen_name VARCHAR,
  OUT id              INT,
  OUT owner_id        INT,
  OUT screen_name     VARCHAR
)
AS $$
  DECLARE
    sn_record RECORD;
  BEGIN
    SELECT "screen_name".id, "screen_name".owner_id, "screen_name".screen_name
    INTO sn_record
    FROM "screen_name"
    WHERE
      parent_id = 0
      AND
      "screen_name".screen_name = screen_name_canonize(raw_screen_name);

    id          := sn_record.id;
    owner_id    := sn_record.owner_id;
    screen_name := sn_record.screen_name;
  END

$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION screen_name_read   ( VARCHAR ) CASCADE;

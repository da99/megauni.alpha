

-- DOWN
SELECT drop_megauni_func('screen_name_insert');

-- UP

CREATE OR REPLACE FUNCTION screen_name_insert(
  IN  raw_owner_id INT,
  IN  raw_screen_name VARCHAR,
  OUT owner_id INT,
  OUT screen_name VARCHAR
)
AS $$
  DECLARE
    sn_record RECORD;
  BEGIN

    INSERT INTO screen_name (owner_id, screen_name)
    VALUES (raw_owner_id, raw_screen_name)
    RETURNING "screen_name".owner_id, "screen_name".screen_name
    INTO sn_record;

    owner_id    := sn_record.owner_id;
    screen_name := sn_record.screen_name;
  END
$$ LANGUAGE plpgsql;




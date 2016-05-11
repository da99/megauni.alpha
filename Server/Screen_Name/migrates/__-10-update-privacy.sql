
-- DOWN
SELECT drop_megauni_func('update_screen_name_privacy');

-- UP
CREATE OR REPLACE FUNCTION update_screen_name_privacy (
  IN USER_ID INT, IN RAW_SN VARCHAR, IN PRIV_NAME VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
  rec     RECORD;
BEGIN
  UPDATE screen_name
  SET privacy = name_to_type_id(PRIV_NAME)
  WHERE id = (SELECT screen_name_id_if_owns_or_fail(USER_ID, RAW_SN))
  RETURNING id
  INTO rec;

  RETURN PRIV_NAME;
END

$$ LANGUAGE plpgsql;


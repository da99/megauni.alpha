
-- BOTH
SELECT drop_megauni_func('update_screen_name_privacy');

-- UP
CREATE OR REPLACE FUNCTION update_screen_name_privacy (
  IN USER_ID INT, IN RAW_SN VARCHAR, IN PRIV_NAME VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
  priv_id SMALLINT;
  rec     RECORD;
BEGIN
  priv_id := name_to_type_id(PRIV_NAME);
  UPDATE screen_name
  SET privacy = priv_id
  WHERE id = screen_name_id_if_owns_or_fail(USER_ID, RAW_SN)
  RETURNING id
  INTO rec;

  RETURN PRIV_NAME;
END

$$ LANGUAGE plpgsql;


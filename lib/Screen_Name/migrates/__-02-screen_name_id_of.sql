
-- DOWN
DROP FUNCTION IF EXISTS     screen_name_id_of         (INT, VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS     screen_name_id_of_or_fail (INT, VARCHAR) CASCADE;

-- UP
CREATE OR REPLACE FUNCTION  screen_name_id_of_or_fail (
  IN USER_ID INT,
  IN RAW_SCREEN_NAME VARCHAR
) RETURNS INT
AS $$
DECLARE
  sn_id INT;
BEGIN
  sn_id := screen_name_id_of(USER_ID, RAW_SCREEN_NAME);
  IF sn_id IS NULL THEN
    RAISE EXCEPTION 'user_error: not owner of screen_name: %', RAW_SCREEN_NAME;
  END IF;

  RETURN sn_id;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION  screen_name_id_of ( IN USER_ID INT, IN RAW_SCREEN_NAME   VARCHAR)
RETURNS INT
AS $$
DECLARE
  sn_record   RECORD;
BEGIN
  SELECT id
  INTO sn_record
  FROM screen_name SN
  WHERE
    SN.screen_name = screen_name_canonize(RAW_SCREEN_NAME)
    AND
    SN.owner_id = USER_ID
  LIMIT 1
  ;
  RETURN sn_record.id;
END
$$ LANGUAGE plpgsql;

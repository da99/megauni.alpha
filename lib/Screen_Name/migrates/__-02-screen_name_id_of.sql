
-- BOTH
SELECT drop_megauni_func('screen_name_id_of');
SELECT drop_megauni_func('screen_name_id_of_or_fail');

-- UP

CREATE OR REPLACE FUNCTION  screen_name_id_of (IN RAW_SCREEN_NAME   VARCHAR)
RETURNS INT
AS $$
DECLARE
  sn_record   RECORD;
BEGIN
  SELECT id
  INTO sn_record
  FROM top_level_screen_name_where(RAW_SCREEN_NAME) SN
  LIMIT 1;
  RETURN sn_record.id;
END
$$ LANGUAGE plpgsql; -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||



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
$$ LANGUAGE plpgsql; -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||



CREATE OR REPLACE FUNCTION  screen_name_id_of (
  IN USER_ID INT,
  IN RAW_SCREEN_NAME   VARCHAR
) RETURNS INT
AS $$
DECLARE
  sn_record   RECORD;
BEGIN
  SELECT id
  INTO sn_record
  FROM top_level_screen_name_where(RAW_SCREEN_NAME) SN
  WHERE
    SN.owner_id = USER_ID
  LIMIT 1
  ;
  RETURN sn_record.id;
END
$$ LANGUAGE plpgsql; -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||



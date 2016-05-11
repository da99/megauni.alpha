
-- DOWN
SELECT drop_megauni_func('screen_name_id_if_owns_or_fail');
-- UP
CREATE OR REPLACE FUNCTION  screen_name_id_if_owns_or_fail (
  IN USER_ID INT, IN RAW_SCREEN_NAME VARCHAR
) RETURNS INT
AS $$
DECLARE
  sn_record RECORD;
BEGIN
  SELECT id
  INTO sn_record
  FROM top_level_screen_name(RAW_SCREEN_NAME) SN
  WHERE
    SN.id = screen_name_id(RAW_SCREEN_NAME)
    AND
    SN.owner_id = USER_ID
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'user_error: not owner of screen_name: %', RAW_SCREEN_NAME;
  END IF;

  RETURN sn_record.id;
END
$$ LANGUAGE plpgsql STABLE; -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||


-- DOWN
SELECT drop_megauni_func('screen_name_id_or_fail');

-- UP
CREATE OR REPLACE FUNCTION screen_name_id_or_fail ( IN USER_ID INT, IN RAW_SCREEN_NAME VARCHAR )
RETURNS INT AS $$
DECLARE
  sn_id INT;
BEGIN
  sn_id := screen_name_id(USER_ID, RAW_SCREEN_NAME);
  IF sn_id IS NULL THEN
    RAISE EXCEPTION 'user_error: not allowed to read: %', RAW_SCREEN_NAME;
  END IF;

  RETURN sn_id;
END
$$ LANGUAGE plpgsql STABLE; -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||

-- UP
CREATE OR REPLACE FUNCTION screen_name_id_or_fail ( IN RAW_SCREEN_NAME VARCHAR )
RETURNS INT AS $$
DECLARE
  sn_id INT;
BEGIN
  sn_id := screen_name_id(RAW_SCREEN_NAME);
  IF sn_id IS NULL THEN
    RAISE EXCEPTION 'user_error: not found: %', RAW_SCREEN_NAME;
  END IF;

  RETURN sn_id;
END
$$ LANGUAGE plpgsql STABLE; -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||


-- DOWN
SELECT drop_megauni_func('screen_name_id');

-- RETURNS SN id if USER_ID can read it.
CREATE OR REPLACE FUNCTION  screen_name_id ( IN USER_ID INT, IN RAW_SCREEN_NAME   VARCHAR)
RETURNS INT AS $$
DECLARE
  sn_record   RECORD;
BEGIN
  SELECT id
  INTO sn_record
  FROM top_level_screen_name(RAW_SCREEN_NAME) SN
  WHERE
    SN.id = screen_name_id(RAW_SCREEN_NAME)
    AND
    can_read(USER_ID, SN.id)
  LIMIT 1
  ;
  RETURN sn_record.id;
END
$$ LANGUAGE plpgsql STABLE; -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||


-- Return id of RAW_SCREEN_NAME:
CREATE OR REPLACE FUNCTION  screen_name_id ( IN RAW_SCREEN_NAME   VARCHAR)
RETURNS INT AS $$
DECLARE
  sn_record   RECORD;
BEGIN
  SELECT id
  INTO sn_record
  FROM top_level_screen_name(RAW_SCREEN_NAME) SN
  LIMIT 1;
  RETURN sn_record.id;
END
$$ LANGUAGE plpgsql STABLE; -- ||||||||||||||||||||||||||||||||||||||||||||||||||||||



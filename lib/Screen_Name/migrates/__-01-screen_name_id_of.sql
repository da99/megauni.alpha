
-- DOWN
DROP FUNCTION IF EXISTS     screen_name_id_of (INT, VARCHAR) CASCADE;

-- UP
CREATE OR REPLACE FUNCTION  screen_name_id_of (
  IN USER_ID       INT,
  IN SCREEN_NAME   VARCHAR
) RETURNS INT
$$
BEGIN
  SELECT id
  FROM screen_name SN
  WHERE
    SN.owner_id = USER_ID
    AND
    SN.parent_id = 0
    AND
    SN.screen_name = screen_name_canonize(SCREEN_NAME);
END
$$ LANGUAGE plpgsql;



-- DOWN
SELECT drop_megauni_func('can_read');

-- UP
CREATE OR REPLACE FUNCTION can_read(IN A_ID INT, IN B_ID INT)
RETURNS BOOLEAN
AS $$
DECLARE
  rec RECORD;
BEGIN
  SELECT true AS answer
  INTO rec
  FROM
  screen_name SN
  WHERE
  SN.id = B_ID
  AND (
    -- Can read self:
    A_ID = B_ID
    OR -- Is world readable:
    SN.privacy = 3
    OR -- In list:
    ( SN.privacy = 2 AND EXISTS (SELECT * FROM in_screen_name_list(A_ID, B_ID)) )
  )
  LIMIT 1;

  IF FOUND THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END
$$ LANGUAGE plpgsql;




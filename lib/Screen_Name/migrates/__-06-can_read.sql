

-- DOWN
DROP FUNCTION              can_read(INT, INT)    CASCADE;
-- UP
CREATE OR REPLACE FUNCTION can_read(IN A_ID INT, IN B_ID INT)
RETURNS TABLE ( answer BOOLEAN )
AS $$
BEGIN
  RETURN QUERY
  SELECT true AS answer
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
  LIMIT 1
  ;
END
$$ LANGUAGE plpgsql;




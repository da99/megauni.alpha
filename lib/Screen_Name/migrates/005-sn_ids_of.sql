
-- DOWN
DROP FUNCTION screen_name_ids_of(INT) CASCADE;

-- UP
CREATE OR REPLACE FUNCTION screen_name_ids_of(IN SN_ID INT)
RETURNS TABLE ( id INT )
AS $$
BEGIN
  RETURN QUERY
  SELECT
    SN.id
  FROM
    screen_name SN
  WHERE
    SN.parent_id = 0
    AND
    SN.owner_id IN (SELECT owner_id FROM screen_name WHERE screen_name.id = SN_ID)
  ;
END
$$ LANGUAGE plpgsql;


-- BOTH
SELECT drop_megauni_func('screen_name_ids');

-- UP
CREATE OR REPLACE FUNCTION screen_name_ids(IN SN_ID INT)
RETURNS TABLE(
  id          INT,
  owner_id    INT,
  screen_name VARCHAR
)
AS $$
BEGIN
  RETURN QUERY
  SELECT
    id, owner_id, screen_name
  FROM
    top_level_screen_name SN
  WHERE
    SN.owner_id IN (
      SELECT owner_id
      FROM screen_name
      WHERE screen_name.id = SN_ID
    )
  ;
END
$$ LANGUAGE plpgsql;

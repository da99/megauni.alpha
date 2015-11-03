
-- BOTH
SELECT drop_megauni_func('top_level_screen_name');

-- UP
CREATE OR REPLACE FUNCTION top_level_screen_name (
  IN RAW_SN VARCHAR
) RETURNS TABLE(
  id          INT,
  owner_id    INT,
  screen_name VARCHAR
)
AS $$
BEGIN
  RETURN QUERY
  SELECT id, owner_id, screen_name
  FROM screen_name
  WHERE
  parent_id = 0
  AND
  screen_name = screen_name_canonize(RAW_SN);
END
$$ LANGUAGE plpgsql;

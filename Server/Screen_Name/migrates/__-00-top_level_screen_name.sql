
-- DOWN
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
  SELECT *
  FROM top_level_screen_name() SN
  WHERE
  SN.screen_name = screen_name_canonize(RAW_SN);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION top_level_screen_name (
  IN RAW_ID INT
) RETURNS TABLE(
  id          INT,
  owner_id    INT,
  screen_name VARCHAR
)
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM  top_level_screen_name() SN
  WHERE id = RAW_ID;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION top_level_screen_name ()
RETURNS TABLE(
  id          INT,
  owner_id    INT,
  screen_name VARCHAR
)
AS $$
BEGIN
  RETURN QUERY
  SELECT SN.id, SN.owner_id, SN.screen_name
  FROM screen_name SN
  WHERE
  parent_id = 0;
END
$$ LANGUAGE plpgsql;

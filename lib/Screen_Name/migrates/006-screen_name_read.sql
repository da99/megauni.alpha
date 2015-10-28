
CREATE FUNCTION screen_name_read(
  IN  raw_screen_name VARCHAR
)
RETURNS TABLE (
  id              INT,
  owner_id        INT,
  screen_name     VARCHAR
)
AS $$
BEGIN
  RETURN QUERY
  SELECT "screen_name".id, "screen_name".owner_id, "screen_name".screen_name
  FROM "screen_name"
  WHERE
  parent_id = 0
  AND
  "screen_name".screen_name = screen_name_canonize(raw_screen_name)
  ;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION screen_name_read(
  IN  sn_id INT
)
RETURNS TABLE (
  id              INT,
  owner_id        INT,
  screen_name     VARCHAR
)
AS $$
BEGIN
  RETURN QUERY
  SELECT
    "screen_name".id,
    "screen_name".owner_id,
    "screen_name".screen_name
  FROM "screen_name"
  WHERE
  parent_id = 0
  AND
  "screen_name".id = sn_id
  ;
END
$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION screen_name_read   ( VARCHAR ) CASCADE;
DROP FUNCTION screen_name_read   ( INT     ) CASCADE;

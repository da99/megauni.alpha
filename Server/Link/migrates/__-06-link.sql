

-- BOTH
SELECT drop_megauni_func('link');

-- UP
CREATE OR REPLACE FUNCTION link (
  IN TYPE_NAME VARCHAR
)
RETURNS TABLE(
  id     INT,
  type_id SMALLINT,
  owner_type_id SMALLINT, owner_id INT,
  a_type_id SMALLINT, a_id INT,
  b_type_id SMALLINT, b_id INT,
  created_at TIMESTAMP WITH TIME ZONE
)
AS $$
DECLARE
  type_ids SMALLINT[];
BEGIN
  type_ids := name_to_type_ids(TYPE_NAME);

  RETURN QUERY
  SELECT
    l.id, l.type_id,
    l.owner_type_id, l.owner_id,
    l.a_type_id,     l.a_id,
    l.b_type_id,     l.b_id,
    l.created_at
  FROM
    link l
  WHERE
    l.type_id        = type_ids[1]
    AND
    l.owner_type_id  = type_ids[2]
    AND
    l.a_type_id      = type_ids[3]
    AND
    l.b_type_id      = type_ids[4]
  ;
END
$$ LANGUAGE plpgsql;

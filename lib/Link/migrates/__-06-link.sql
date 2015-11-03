

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
    id, type_id, owner_type_id, owner_id,
    a_type_id, a_id,
    b_type_id, b_id,
    created_at
  FROM
    link
  WHERE
    type_id        = type_ids[1]
    AND
    owner_type_id  = type_ids[2]
    AND
    a_type_id      = type_ids[3]
    AND
    b_type_id      = type_ids[4]
  ;
END
$$ LANGUAGE plpgsql;

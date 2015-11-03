

-- BOTH
SELECT drop_megauni_func('link');

-- UP
CREATE OR REPLACE FUNCTION link (
  IN TYPE_NAME VARCHAR
)
RETURNS SETOF link
AS $$
DECLARE
  type_ids SMALLINT[];
BEGIN
  type_ids := name_to_type_ids(TYPE_NAME);

  RETURN QUERY
  SELECT
    link.*
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

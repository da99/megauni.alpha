



-- BOTH
SELECT drop_megauni_func('last_read_of');

-- UP
CREATE FUNCTION last_read_of(IN SN_ID INT)
RETURNS TABLE (
  publication_id INT,
  at             TIMESTAMP WITH TIME ZONE
)
AS $$
BEGIN
  RETURN QUERY
  SELECT
    link.b_id       AS publication_id,
    link.created_at AS at
  FROM
    link
  WHERE
    link.type_id  = 22
    AND
    link.owner_id IN (
      SELECT owner_id
      FROM screen_name_read(SN_ID)
      LIMIT 1
    )
    AND link.a_id = link.owner_id
  ;
END
$$ LANGUAGE plpgsql;




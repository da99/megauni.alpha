



-- BOTH
SELECT drop_megauni_func('follow');

-- UP
-- 'follow' always provide all screen names, including
-- the ones that can not be seen by SN_ID.
-- This is because the privacy settings of 'card' takes
-- precedence over the privacy setting of the publication/sn.
-- For example: a SN may be entirely private, but some cards
-- can be marked 'world readable bypassing sn privacy'.
CREATE FUNCTION follow(IN SN_ID INT)
RETURNS TABLE (
  mask_id        INT,
  publication_id INT,
  created_at     TIMESTAMP WITH TIME ZONE
)
AS $$
BEGIN
  RETURN QUERY
  SELECT
    link.a_id AS mask_id,
    link.b_id AS publication_id,
    link.created_at
  FROM
    link
  WHERE
    type_id = 23
    AND owner_id = a_id -- 'follows' can only be made by sn
    AND owner_id IN (SELECT sn.id FROM screen_name_ids(SN_ID))
  ;
END
$$ LANGUAGE plpgsql;






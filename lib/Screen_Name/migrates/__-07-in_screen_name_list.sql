

-- DOWN
SELECT drop_megauni_func('in_screen_name_list');



-- UP
CREATE OR REPLACE FUNCTION in_screen_name_list(IN AUD_ID INT, IN SN_ID INT)
RETURNS TABLE ( mask_id INT )
AS $$
BEGIN
  RETURN QUERY
  SELECT a_id AS mask_id
  FROM
    link
  WHERE
    type_id = 12 AND
    owner_id = b_id AND
    a_id IN (SELECT id FROM sn_ids_of(AUD_ID))
  LIMIT 1;
END
$$ LANGUAGE plpgsql;



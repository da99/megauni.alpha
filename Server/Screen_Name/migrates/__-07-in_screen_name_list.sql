

-- DOWN
SELECT drop_megauni_func('in_screen_name_list');



-- UP
CREATE OR REPLACE FUNCTION in_screen_name_list(IN AUD_ID INT, IN SN_ID INT)
RETURNS BOOLEAN
AS $$
DECLARE
  rec RECORD;
BEGIN
  SELECT a_id AS mask_id
  INTO rec
  FROM
    link
  WHERE
    type_id = name_to_type_id('ALLOW TO READ') AND
    owner_id = b_id AND
    a_id IN (SELECT id FROM sn_ids_of(AUD_ID))
  LIMIT 1;

  IF FOUND THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END
$$ LANGUAGE plpgsql;



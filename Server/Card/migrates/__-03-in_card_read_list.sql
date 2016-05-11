



-- DOWN
SELECT drop_megauni_func('in_card_read_list');

-- UP
CREATE FUNCTION in_card_read_list(IN SN_ID INT, IN CARD_ID INT)
RETURNS BOOLEAN AS $$
DECLARE
  rec RECORD;
BEGIN
  SELECT
    TRUE AS answer
  INTO rec
  FROM
    link('ALLOW TO READ | SN, CARD, SN') link
  WHERE
    -- Make sure owner of card granted permission:
    owner_id IN (SELECT owner_id FROM card WHERE card.id = CARD_ID)
    AND
    a_id IN (SELECT id FROM screen_name_ids(SN_ID))
    AND
    b_id = CARD_ID
  LIMIT 1;

  IF FOUND THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END
$$ LANGUAGE plpgsql;




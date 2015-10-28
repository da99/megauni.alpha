



-- DOWN
DROP FUNCTION   in_card_read_list_of(INT, INT)   CASCADE;
-- UP
CREATE FUNCTION in_card_read_list_of(IN SN_ID INT, IN CARD_ID INT)
RETURNS TABLE ( answer BOOLEAN ) AS $$
DECLARE
  LINK_ALLOW_TO_READ_CARD CONSTANT INT := 24;
BEGIN
  RETURN QUERY
  SELECT
    TRUE AS answer
  FROM
    link
  WHERE
    type_id = LINK_ALLOW_TO_READ_CARD
    AND -- Make sure owner of card granted permission:
    owner_id IN (SELECT owner_id FROM card WHERE card.id = CARD_ID)
    AND
    a_id IN (SELECT id FROM sn_ids_of(SN_ID))
    AND
    b_id = CARD_ID
  LIMIT 1
  ;
END
$$ LANGUAGE plpgsql;




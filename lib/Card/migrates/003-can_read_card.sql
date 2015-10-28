



-- DOWN
DROP FUNCTION   can_read_card(INT, INT)          CASCADE;
-- UP
CREATE FUNCTION can_read_card(IN SN_ID INT, IN CARD_ID INT)
RETURNS TABLE ( answer BOOLEAN ) AS $$
BEGIN
  RETURN QUERY
  SELECT
    true AS answer
  FROM
    card
  WHERE
    -- WORLD READable, bypassing SN permission
    card.privacy = 4

    OR
    -- SAME AS SN:
    ( card.privacy = 3 AND EXISTS (SELECT * FROM can_read(SN_ID, card.owner_id)) )

    OR
    -- AUD must be on list allowed card readers to read:
    ( card.privacy = 2 AND EXISTS (SELECT * FROM in_card_read_list_of(SN_ID, card.id)) )
  LIMIT 1
  ;
END
$$ LANGUAGE plpgsql;



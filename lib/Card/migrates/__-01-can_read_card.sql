



-- DOWN
DROP FUNCTION IF EXISTS  can_read_card         (INT, INT) CASCADE;
DROP FUNCTION IF EXISTS  can_read_card_or_fail (INT, INT) CASCADE;

-- UP
CREATE OR REPLACE FUNCTION can_read_card_or_fail (
  IN SN_ID INT, IN CARD_ID INT
)
RETURNS BOOLEAN AS $$
DECLARE
  answer BOOLEAN;
BEGIN
  IF can_read_card(SN_ID, CARD_ID) THEN
    RETURN TRUE;
  END IF;

  RAISE EXCEPTION 'user_error: no permission read: card';
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION can_read_card (IN SN_ID INT, IN CARD_ID INT)
RETURNS BOOLEAN AS $$
DECLARE
  rec RECORD;
BEGIN
  SELECT
    true AS answer
  INTO rec
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

  IF FOUND THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END
$$ LANGUAGE plpgsql;



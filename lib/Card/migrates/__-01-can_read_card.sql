



-- BOTH
SELECT drop_megauni_func('can_read_card');
SELECT drop_megauni_func('can_read_card_or_fail');
SELECT drop_megauni_func('return_card_id_or_fail');

-- UP
CREATE OR REPLACE FUNCTION return_card_id_or_fail (
  IN SN_ID INT, IN CARD_ID INT
)
RETURNS INT AS $$
BEGIN
  IF can_read_card_or_fail(SN_ID, CARD_ID) THEN
    RETURN CARD_ID;
  END IF;
END
$$ LANGUAGE plpgsql;

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
    card.privacy = name_to_type_id('WORLD READABLE')

    OR
    -- SAME AS SN:
    ( card.privacy = name_to_type_id('SAME AS OWNER') AND EXISTS (SELECT * FROM can_read(SN_ID, card.owner_id)) )

    OR
    -- AUD must be on list allowed card readers to read:
    ( card.privacy = name_to_type_id('LIST ONLY') AND EXISTS (SELECT * FROM in_card_read_list(SN_ID, card.id)) )
  LIMIT 1
  ;

  IF FOUND THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END
$$ LANGUAGE plpgsql;





-- BOTH
SELECT drop_megauni_func('card_id_or_fail');


-- UP

CREATE OR REPLACE FUNCTION card_id_or_fail (
  IN SN_ID INT, IN CARD_ID INT
)
RETURNS INT AS $$
BEGIN
  IF can_read_card_or_fail(SN_ID, CARD_ID) THEN
    RETURN CARD_ID;
  END IF;
END
$$ LANGUAGE plpgsql;



-- DOWN
DROP FUNCTION IF EXISTS `can_read_card_or_fail`;

-- UP

DELIMITER //

CREATE FUNCTION can_read_card_or_fail (
  SN_ID   INT,
  CARD_ID INT
)
RETURNS BOOLEAN
NOT DETERMINISTIC
READS SQL DATA
BEGIN
  IF can_read_card(SN_ID, CARD_ID) THEN
    RETURN TRUE;
  END IF;

  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_error: no permission read: card';
END //


-- DOWN
DROP FUNCTION IF EXISTS `can_read_card`;

-- UP
CREATE FUNCTION can_read_card (
  SN_ID   INT,
  CARD_ID INT
)
RETURNS BOOLEAN
NOT DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE WAS_FOUND BOOLEAN DEFAULT FALSE;
  SELECT
    true AS answer
  INTO WAS_FOUND
  FROM
    card
  WHERE
    -- WORLD READable, bypassing SN permission
    card.privacy = name_to_type_id('WORLD READABLE')

    OR
    -- SAME AS SN:
    ( card.privacy = name_to_type_id('SAME AS OWNER') AND can_read(SN_ID, card.owner_id) )

    OR
    -- AUD must be on list allowed card readers to read:
    ( card.privacy = name_to_type_id('LIST ONLY') AND in_card_read_list(SN_ID, card.id) )
  LIMIT 1
  ;

  IF WAS_FOUND THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END //

DELIMITER ;



Function	sql_mode	Create Function	character_set_client	collation_connection	Database Collation
can_read_card	NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`megauni`@`localhost` FUNCTION `can_read_card`(
  SN_ID   INT,
  CARD_ID INT
) RETURNS tinyint(1)
    READS SQL DATA
BEGIN
  DECLARE WAS_FOUND BOOLEAN DEFAULT FALSE;
  SELECT
    true AS answer
  INTO WAS_FOUND
  FROM
    card
  WHERE
    
    card.privacy = name_to_type_id('WORLD READABLE')
    OR
    
    ( card.privacy = name_to_type_id('SAME AS OWNER') AND can_read(SN_ID, card.owner_id) )
    OR
    
    ( card.privacy = name_to_type_id('LIST ONLY') AND in_card_read_list(SN_ID, card.id) )
  LIMIT 1
  ;
  IF WAS_FOUND THEN
    RETURN TRUE;
  END IF;
  RETURN FALSE;
END	utf8	utf8_general_ci	utf8_general_ci

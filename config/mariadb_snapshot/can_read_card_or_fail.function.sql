Function	sql_mode	Create Function	character_set_client	collation_connection	Database Collation
can_read_card_or_fail	NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`megauni`@`localhost` FUNCTION `can_read_card_or_fail`(
  SN_ID   INT,
  CARD_ID INT
) RETURNS tinyint(1)
    READS SQL DATA
BEGIN
  IF can_read_card(SN_ID, CARD_ID) THEN
    RETURN TRUE;
  END IF;
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'user_error: no permission read: card';
END	utf8	utf8_general_ci	utf8_general_ci

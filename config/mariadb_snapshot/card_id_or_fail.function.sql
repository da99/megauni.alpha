Function	sql_mode	Create Function	character_set_client	collation_connection	Database Collation
card_id_or_fail	NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`megauni`@`localhost` FUNCTION `card_id_or_fail`(
  SN_ID   INT,
  CARD_ID INT
) RETURNS int(11)
    READS SQL DATA
BEGIN
  IF can_read_card_or_fail(SN_ID, CARD_ID) THEN
    RETURN CARD_ID;
  END IF;
END	utf8	utf8_general_ci	utf8_general_ci

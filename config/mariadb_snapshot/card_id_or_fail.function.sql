Function	sql_mode	Create Function	character_set_client	collation_connection	Database Collation
card_id_or_fail	NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`megauni`@`localhost` FUNCTION `card_id_or_fail`(\n  SN_ID   INT,\n  CARD_ID INT\n) RETURNS int(11)\n    READS SQL DATA\nBEGIN\n  IF can_read_card_or_fail(SN_ID, CARD_ID) THEN\n    RETURN CARD_ID;\n  END IF;\nEND	utf8	utf8_general_ci	utf8_general_ci

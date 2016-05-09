Function	sql_mode	Create Function	character_set_client	collation_connection	Database Collation
name_to_type_id	NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`megauni`@`localhost` FUNCTION `name_to_type_id`(
  NAME VARCHAR(255)
) RETURNS smallint(6)
    READS SQL DATA
BEGIN
  DECLARE MSG_TXT VARCHAR(255) DEFAULT 'NO ERROR';
  CASE NAME
  WHEN 'USER'                                THEN RETURN 1;
  WHEN 'SCREEN_NAME' OR 'SN'                 THEN RETURN 2;
  WHEN 'CARD'                                THEN RETURN 3;
  WHEN 'ME ONLY'                             THEN RETURN 10;
  WHEN 'LIST ONLY'                           THEN RETURN 11;
  WHEN 'WORLD READABLE'                      THEN RETURN 12;
  WHEN 'SAME AS OWNER'                       THEN RETURN 13;
  WHEN 'LIST AND OWNER LIST'                 THEN RETURN 14;
  WHEN 'BLOCK'                               THEN RETURN 20; 
  WHEN 'BLOCK ALL SCREEN_NAMES'              THEN RETURN 21; 
  WHEN 'ALLOW TO CREATE'                     THEN RETURN 31;  
  WHEN 'ALLOW TO READ'                       THEN RETURN 32;  
  WHEN 'LINK'                                THEN RETURN 40; 
  WHEN 'LAST READ AT'                        THEN RETURN 90;  
  WHEN 'FOLLOW'                              THEN RETURN 91;  
  ELSE
    SELECT CONCAT('programmer_error: name for type_id not found: ', NAME)
    INTO MSG_TXT;
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = MSG_TXT;
  END CASE;
END	utf8	utf8_general_ci	utf8_general_ci

Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
i_follow_screen_name	NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`megauni`@`localhost` PROCEDURE `i_follow_screen_name`(
  IN  OWNER_ID            INT,
  IN  OWNER_SCREEN_NAME   VARCHAR(255),
  IN  TARGET_SCREEN_NAME  VARCHAR(255),
  OUT LINK_ID             INT
)
BEGIN
  DECLARE OWNER_SN_ID INT DEFAULT screen_name_id_if_owns_or_fail(OWNER_ID, OWNER_SCREEN_NAME);
  DECLARE FOLLOW_TYPE SMALLINT DEFAULT name_to_type_id('FOLLOW');
  DECLARE SN_TYPE     SMALLINT DEFAULT name_to_type_id('SCREEN_NAME');
  DECLARE TARGET_ID   INT DEFAULT screen_name_id_or_fail(OWNER_ID, TARGET_SCREEN_NAME);
  call link_insert(
    FOLLOW_TYPE,
    
    SN_TYPE, OWNER_SN_ID,
    
    SN_TYPE, OWNER_SN_ID,
    
    SN_TYPE, TARGET_ID,
    LINK_ID
  );
END	utf8	utf8_general_ci	utf8_general_ci

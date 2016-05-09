Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
show_me	NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`megauni`@`localhost` PROCEDURE `show_me`(
)
BEGIN
  SELECT * FROM file_name;
END	utf8	utf8_general_ci	utf8_general_ci

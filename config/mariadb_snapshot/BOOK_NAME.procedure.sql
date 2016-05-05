Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
BOOK_NAME	NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`megauni`@`localhost` PROCEDURE `BOOK_NAME`(OUT target SMALLINT)\nBEGIN\n  SELECT COUNT(*) AS total\n  INTO target\n  FROM BOOKS;\nEND	utf8	utf8_general_ci	utf8_general_ci

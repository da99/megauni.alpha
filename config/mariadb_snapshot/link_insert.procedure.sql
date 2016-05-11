Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
link_insert	NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`megauni`@`localhost` PROCEDURE `link_insert`(
  IN  TYPE_ID        INT,
  IN  OWNER_TYPE_ID  INT, IN OWNER_ID INT,
  IN  A_TYPE_ID      INT, IN  A_ID    INT,
  IN  B_TYPE_ID      INT, IN  B_ID    INT,
  OUT LINK_ID        INT
)
BEGIN
  INSERT INTO link (
    type_id,
    owner_type_id, owner_id,
    a_type_id,     a_id,
    b_type_id,     b_id
  )
  VALUES (
   TYPE_ID,
   OWNER_TYPE_ID, OWNER_ID,
   A_TYPE_ID,     A_ID   ,
   B_TYPE_ID,     B_ID
  );
  SELECT LAST_INSERT_ID() as id INTO LINK_ID;
END	utf8	utf8_general_ci	utf8_general_ci



-- DOWN
DROP PROCEDURE IF EXISTS link_insert;

-- UP
DELIMITER //

CREATE OR REPLACE PROCEDURE link_insert (
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
END //



DELIMITER ;


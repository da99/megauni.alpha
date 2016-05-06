
-- DOWN
DROP FUNCTION IF EXISTS name_to_type_id;

-- UP

DELIMITER //

CREATE OR REPLACE FUNCTION name_to_type_id (
  NAME VARCHAR(255)
)
RETURNS SMALLINT
NOT DETERMINISTIC
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

  WHEN 'BLOCK'                               THEN RETURN 20; -- # meanie  -> me
  WHEN 'BLOCK ALL SCREEN_NAMES'              THEN RETURN 21; -- # meanie  -> me

  WHEN 'ALLOW TO CREATE'                     THEN RETURN 31;  -- # friend  -> target
  WHEN 'ALLOW TO READ'                       THEN RETURN 32;  -- # friend  -> target

  WHEN 'LINK'                                THEN RETURN 40; -- # sn_id, card.id -> sn.id

  WHEN 'LAST READ AT'                        THEN RETURN 90;  --  # owner_id -> owner_id => sn.id
  WHEN 'FOLLOW'                              THEN RETURN 91;  --  # sn, sn -> target
  ELSE
    SELECT CONCAT('programmer_error: name for type_id not found: ', NAME)
    INTO MSG_TXT;
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = MSG_TXT;
  END CASE;
END//

DELIMITER ;


-- DOWN
DROP FUNCTION IF EXISTS `card_insert`;

-- UP
DELIMITER //
CREATE FUNCTION card_insert (
  USER_ID      INT,
  RAW_SN       VARCHAR(255),
  PRIVACY_NAME VARCHAR(255),
  CODE         VARCHAR(255)
) RETURNS TABLE( id INT )
BEGIN
  RETURN QUERY
  INSERT INTO card (
    owner_id,
    privacy,
    code
  )
  VALUES (
    screen_name_id_if_owns_or_fail(USER_ID, RAW_SN),
    name_to_type_id(PRIVACY_NAME),
    CODE::JSONB
  ) RETURNING card.id;

END //
DELIMITER ;

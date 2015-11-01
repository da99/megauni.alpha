


-- DOWN
DROP FUNCTION IF EXISTS    link_insert ( INT, VARCHAR, INT, VARCHAR ) CASCADE ;

-- UP
CREATE OR REPLACE FUNCTION link_insert (
  IN USER_ID      INT,
  IN TYPE_NAME    VARCHAR,
  IN A_ID         INT,
  IN SCREEN_NAME  VARCHAR
) RETURNS TABLE(id INT)
AS $$
BEGIN
  CASE TYPE_NAME
  WHEN 'LINK | CARD, SN', 'LINK | CARD, SCREEN_NAME' THEN
    RETURN QUERY
    INSERT INTO link (
      type_id,
      owner_id, owner_type_id,
      a_type_id, a_id,
      b_type_id, b_id
    )
    VALUES (
      name_to_type_id('LINK'),

      name_to_type_id('SN'),
      screen_name_id_of_or_fail(USER_ID, SCREEN_NAME),

      name_to_type_id('CARD'),
      return_card_id_or_fail(USER_ID, A_ID),

      name_to_type_id('SN'),
      screen_name_id_of_or_fail(USER_ID, SCREEN_NAME)
    ) RETURNING link.id;
  ELSE
    RAISE EXCEPTION 'programmer_error: unknown link_insert type: %', TYPE_NAME;
  END CASE;
END
$$ LANGUAGE plpgsql;

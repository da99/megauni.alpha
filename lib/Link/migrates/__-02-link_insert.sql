


-- DOWN
DROP FUNCTION IF EXISTS    link_insert ( INT, VARCHAR, INT, VARCHAR ) CASCADE ;

-- UP
CREATE OR REPLACE FUNCTION link_insert (
  IN OWNER_ID     INT,
  IN TYPE_NAME    VARCHAR,
  IN A_ID         INT,
  IN SCREEN_NAME  VARCHAR
) RETURNS SMALLINT[]
AS $$
DECLARE
BEGIN
  CASE TYPE_NAME
  WHEN 'LINK | CARD, SN', 'LINK | CARD, SCREEN_NAME' THEN
    INSERT INTO link (owner_id, type_id, a_type_id, a_id, b_type_id, b_id)
    VALUES (
      OWNER_ID,

      name_to_link_type_id('LINK'),

      name_to_type_id('CARD'),
      can_read_card_or_fail(USER_ID, A_ID),

      name_to_type_id('SN'),
      screen_name_id_of_or_fail(OWNER_ID, SCREEN_NAME)
    );
  ELSE
    RAISE EXCEPTION 'programmer_error: unknown link_insert type: %', TYPE_NAME;
  END CASE;
END
$$ LANGUAGE plpgsql;

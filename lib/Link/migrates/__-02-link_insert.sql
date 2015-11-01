


-- DOWN
DROP FUNCTION IF EXISTS    link_insert ( INT, VARCHAR, INT, VARCHAR ) CASCADE ;

-- UP
CREATE OR REPLACE FUNCTION link_insert (
  IN OWNER_ID     INT,
  IN TYPE_NAME    VARCHAR,
  IN OBJ_ID       INT,
  IN SCREEN_NAME  VARCHAR
) RETURNS SMALLINT[]
AS $$
DECLARE
BEGIN
  CASE TYPE_NAME
  WHEN 'LINK | CARD, SN', 'LINK | CARD, SCREEN_NAME' THEN
    INSERT INTO link (owner_id, type_id, a_id, a_type_id, b_id, b_type_id)
    VALUES (
      OWNER_ID,
      name_to_type_id(TYPE_NAME),
      OBJ_ID,
      name_to_type_id('CARD'),
      screen_name_id_of(OWNER_ID, SCREEN_NAME),
      name_to_type_id('SN')
    );
  ELSE
    RAISE EXCEPTION 'programmer_error: unknown link_insert type: %', TYPE_NAME;
  END CASE;
END
$$ LANGUAGE plpgsql;

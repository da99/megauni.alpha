
-- BOTH
SELECT drop_megauni_func('card_insert');

-- UP

CREATE FUNCTION card_insert (
  IN USER_ID INT,
  IN SN      VARCHAR,
  IN PRIVACY_NAME VARCHAR,
  IN CODE    VARCHAR
) RETURNS TABLE( id INT )
AS $$
DECLARE
BEGIN
  RETURN QUERY
  INSERT INTO card (
    owner_id,
    privacy,
    code
  )
  VALUES (
    screen_name_id_or_fail(USER_ID, SN),
    name_to_type_id(PRIVACY_NAME),
    CODE::JSONB
  ) RETURNING card.id;

END
$$ LANGUAGE plpgsql;

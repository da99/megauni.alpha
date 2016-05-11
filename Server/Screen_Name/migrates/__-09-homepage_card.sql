

--
-- Results:
--   publication_id (sn id)     |
--   'publication_screen_name'  |
--   card_id                    |
--   card_code                  |
--   linked_at                  |
--   card_created_at
--
--   ORDER BY link.created_at DESC
--

-- DOWN
SELECT drop_megauni_func('homepage_card');

-- UP
CREATE OR REPLACE FUNCTION homepage_card(
  IN AUDIENCE_USER_ID INT,
  IN RAW_SCREEN_NAME VARCHAR
) RETURNS TABLE (
  publication_id          INT,
  publication_screen_name VARCHAR,
  card_id                 INT,
  card_code               JSONB,
  linked_at               TIMESTAMP WITH TIME ZONE,
  created_at              TIMESTAMP WITH TIME ZONE
)
AS $$
BEGIN

  RETURN QUERY
    SELECT
      screen_name.id          AS publication_id,
      screen_name.screen_name AS publication_screen_name,
      card.id                 AS card_id,
      card.code               AS card_code,
      link.created_at         AS linked_at,
      card.created_at         AS card_created_at

    FROM
      link('LINK | CARD, SCREEN_NAME') AS link,
      card,
      screen_name

    WHERE
      -- For now: only owner of SN can link cards.
      link.owner_id = screen_name_id(RAW_SCREEN_NAME)
      AND
      can_read(AUDIENCE_USER_ID, link.owner_id)
      AND
      card.id = link.a_id
      AND
      screen_name.id = link.b_id
      AND
      can_read_card(AUDIENCE_USER_ID, card.id)

    ORDER BY link.created_at DESC
  ;
END
$$ LANGUAGE plpgsql;





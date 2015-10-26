
--
-- This function is meant to be used as:
--    SELECT * FROM link_read(link_type_id, aud_user_id)
--    WHERE ....
--    LIMIT  NUM;

-- Implementation:
--
-- Results:
--   following "publication_sn1" as "my_sn_1"    date of last post
--   following "publication_sn2" as "my_sn_1"    date of last post
--   following "publication_sn2" as "my_sn_2"    date of last post
--   following "publication_sn3" as "my_sn_1"    null (nothing posted since last read)
--   following "publication_sn4" as "my_sn_2"    null (nothing posted since last read)
--
CREATE FUNCTION news_of( IN USER_ID  INT)
RETURNS TABLE (
  mask_id                 INT,
  mask_screen_name        VARCHAR,
  publication_id          INT,
  publication_screen_name VARCHAR,
  created_at              TIMESTAMP WITH TIME ZONE
)
AS $$
BEGIN

  RETURN QUERY

    SELECT
      FIELDS

    FROM
      follow(AUDIENCE_USER_ID)         AS follow

      LEFT JOIN link AS link_card
      ON link_card.type_id = 20 AND link_card.b_id = follow.b_id

      LEFT JOIN card
      ON
        link_card.a_id = card.id
        AND
        card.created_at > last_read.at

    WHERE
      allowed(audience, publication, card_owner)
      AND
      card_allowed_to_be_read(audience, publication)

    ORDER BY last_card.created_at DESC
  ;
END
$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION news_of(INT) CASCADE;



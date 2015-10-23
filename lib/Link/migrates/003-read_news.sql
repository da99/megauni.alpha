
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
CREATE FUNCTION allowed_news(
  IN AUDIENCE_USER_ID    INT
)
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
      follow.mask_id,
      follow.mask_screen_name,
      follow.publication_id,
      follow.publication_screen_name,
      last_card.created_at

    FROM
      allowed_follow(AUDIENCE_ID)              AS follow
      LEFT JOIN allowed_last_card(AUDIENCE_ID) AS last_card
      ON follow.publication_id = last_card.publication_id

    ORDER BY last_card.created_at DESC

  RETURN; -- |||||||||||||||||||||||||||||||||||||||||||||||||||

END
$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION allowed_news(INT) CASCADE;



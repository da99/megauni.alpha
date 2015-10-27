
--
-- This function is meant to be used as:
--    SELECT * FROM link_read(link_type_id, aud_user_id)
--    WHERE ....
--    LIMIT  NUM;

-- Implementation:
--
-- Results:
--   "my_sn_1" "publication_sn1"                 date of last post
--   "my_sn_2" "publication_sn2"                 date of last post
--   "my_sn_3" "publication_sn2"                 date of last post
--   "my_sn_3" "publication_sn3"                 null (nothing posted since last read)
--   "my_sn_4" "publication_sn4"                 null (nothing posted since last read)
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
      follow.mask_id        AS mask_id,
      follow.publication_id AS publication_id
      MAX(card.created_at)  AS card_created_at

    FROM
      follows_of(USER_ID)  AS follow
      LEFT JOIN
      ( -- We make sure cards are viewable by both publication_id and AUD/USER id
        posted_cards() AS posted_cards
        INNER JOIN
        card_ids_readable_for(USER_ID) AS aud_cards
        ON posted_cards.id = aud_cards.id
      ) AS cards
      ON follow.publication_id = cards.publication_id

    GROUP BY follow.mask_id, follow.publication_id
  ;
END
$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION news_of(INT) CASCADE;



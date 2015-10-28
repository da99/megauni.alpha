
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

-- DOWN
DROP FUNCTION news_of(INT) CASCADE;

-- UP
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
      follow.mask_id                AS mask_id,
      follow.publication_id         AS publication_id,
      MAX(linked_cards.linked_at)   AS linked_at

    FROM
      follows_of(USER_ID)        follow
      LEFT JOIN
      linked_cards_for(USER_ID)  linked_cards
      ON
      follow.publication_id = linked_cards.publication_id
      AND EXISTS can_read_card(follow.publication_id)

    GROUP BY follow.mask_id, follow.publication_id
  ;
END
$$ LANGUAGE plpgsql;



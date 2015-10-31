


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
  publication_id          INT,
  updated_at              TIMESTAMP WITH TIME ZONE,
  last_read_at            TIMESTAMP WITH TIME ZONE
)
AS $$
BEGIN

  RETURN QUERY

    SELECT
      follow.mask_id                AS mask_id,
      follow.publication_id         AS publication_id,
      MAX(card.linked_at)           AS updated_at,
      last_read.at                  AS last_read_at

    FROM
      follows_of(USER_ID)        follow

      LEFT OUTER JOIN
      linked_cards_for(USER_ID)  card
      ON
      follow.publication_id = card.publication_id

      LEFT OUTER JOIN
      last_read_of(USER_ID)      last_read
      ON
      follow.publication_id = last_read.publication_id

    GROUP BY follow.mask_id, follow.publication_id, last_read.at
    ORDER BY updated_at DESC NULLS LAST
  ;
END
$$ LANGUAGE plpgsql;




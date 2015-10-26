

CREATE OR REPLACE FUNCTION user_id_in_allow_list_of(IN USER_ID INT, IN SN_ID INT)
RETURNS TABLE ( id INT )
AS $$
BEGIN
  RETURN QUERY
  SELECT mask.id AS id
  FROM
    link INNER JOIN screen_name_ids_of_owner_id(USER_ID) AS mask
    ON type_id = 12 AND
    owner_id = SN_ID AND owner_id = b_id AND
    a_id = mask.id
  LIMIT 1;
END
$$ LANGUAGE plpgsql;


CREATE FUNCTION screen_name_ids_readable_for(IN USER_ID INT)
RETURNS TABLE (id INT)
AS $$
BEGIN
  RETURN QUERY
  SELECT id AS id
  FROM screen_name
  WHERE
    (
      screen_name.privacy = 2 AND
      EXISTS (
        SELECT sn.id
        FROM user_id_in_allow_list_of(USER_ID, id) AS sn
      )
    )
    OR
    screen_name.privacy = 3 -- WORLD read_able
  ;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION raw_follows_of(IN USER_ID INT)
RETURNS TABLE ( publication_id INT )
AS $$
BEGIN
  RETURN QUERY
  SELECT
    link.b_id AS publication_id
  FROM
    link
  WHERE
    type_id = 23
    AND owner_id = a_id
    AND owner_id IN (
      SELECT sn.id
      FROM screen_name_ids_for_owner_id(USER_ID) sn
    )
  ;
END
$$ LANGUAGE plpgsql;


-- Results:
--   mask id |  pub id  | follow created at
CREATE OR REPLACE FUNCTION follows_of(IN USER_ID INT)
RETURNS TABLE (
  mask_id        INT,
  publication_id INT,
  followed_at    TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    follow.owner_id         AS mask_id,
    follow.b_id             AS publication_id,
    follow.created_at       AS followed_at

  FROM
    raw_follows_of(USER_ID) AS follow
    INNER JOIN
    screen_name_ids_readable_for(USER_ID) AS people
    ON
    follow.a_id = people.a_id AND
    follow.b_id = people.b_id
  ;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION card_ids_readable_for(IN USER_ID INT)
RETURNS TABLE ( id INT ) AS $$
BEGIN
  RETURN QUERY
  SELECT
    card.id
  FROM
    card
  WHERE
    -- AUD must be on list to read:
    ( card.privacy = 2 AND EXISTS (SELECT id FROM user_id_in_allow_list_for_card_of(USER_ID, card.id)) )

    OR -- AUD can see screen_name? Then can see card:
    ( card.privacy = 3 AND card.owner_id IN (SELECT id FROM screen_name_ids_readable_for(USER_ID)) )

    OR -- bypasses screen_name privacy:
    card.privacy = 4
  ;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION last_read(IN USER_ID INT)
RETURNS TABLE ( owner_id INT, publication_id INT, last_at TIMESTAMP WITH TIME ZONE )
AS $$
BEGIN
  RETURN QUERY
  SELECT
    link_reads_at.a_id       AS owner_id,
    link_reads_at.b_id       AS publication_id,
    link_reads_at.created_at AS last_at
  FROM
    link         AS link_reads_at
  WHERE
    link_cards.type_id  = 22
    AND
    link.owner_id IN (
      SELECT owner_id
      FROM screen_name_read(AUDIENCE_USER_ID)
    )
    AND link.a_id = link.owner_id
  ;
END
$$ LANGUAGE plpgsql;


-- DOWN


DROP FUNCTION user_id_in_allow_list_of(INT, INT)  CASCADE;
DROP FUNCTION screen_name_ids_readable_for(INT)   CASCADE;
DROP FUNCTION raw_follows_of(INT)                 CASCADE;
DROP FUNCTION follows_of(INT)                     CASCADE;
DROP FUNCTION card_ids_readable_for(INT)          CASCADE;
DROP FUNCTION last_read(INT)                      CASCADE;




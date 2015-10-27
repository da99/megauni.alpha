
-- DOWN
DROP FUNCTION              can_read(INT, INT)    CASCADE;
-- UP
CREATE OR REPLACE FUNCTION can_read(IN A_ID INT, IN B_ID INT)
RETURNS TABLE ( publication_id INT )
AS $$
BEGIN
  RETURN QUERY
  SELECT SN.id AS publication_id
  FROM
  screen_name SN
  WHERE
  SN.id = B_ID
  AND (
    SN.privacy = 3 -- is world_read
    OR -- in list
    ( SN.privacy = 2 AND EXISTS (SELECT is_one FROM in_sn_list_of(A_ID, B_ID)) )
  )
  ;
END
$$ LANGUAGE plpgsql;



-- DOWN
DROP FUNCTION              in_sn_list_of(INT, INT)  CASCADE;
-- UP
CREATE OR REPLACE FUNCTION in_sn_list_of(IN SN_ID INT, IN SN_ID INT)
RETURNS TABLE ( is_one INT )
AS $$
BEGIN
  RETURN QUERY
  SELECT 1 AS is_one
  FROM
    link INNER JOIN sn_ids_of(USER_ID) AS mask
    ON type_id = 12 AND
    owner_id = SN_ID AND owner_id = b_id AND
    a_id = mask.id
  LIMIT 1;
END
$$ LANGUAGE plpgsql;


-- DOWN
DROP FUNCTION   raw_follows_of(INT)                 CASCADE;
--UP
CREATE FUNCTION raw_follows_of(IN USER_ID INT)
RETURNS TABLE ( publication_id INT )
AS $$
BEGIN
  RETURN QUERY
  SELECT
    link.a_id AS mask_id,
    link.b_id AS publication_id
  FROM
    link
  WHERE
    type_id = 23
    AND owner_id = a_id
    AND owner_id IN (SELECT sn.id FROM sn_ids_of(USER_ID) sn)
  ;
END
$$ LANGUAGE plpgsql;


-- DOWN
DROP FUNCTION   follows_of(INT)                     CASCADE;
-- UP
-- Results:
--   mask id |  pub id  | follow created at
CREATE FUNCTION follows_of(IN USER_ID INT)
RETURNS TABLE (
  mask_id        INT,
  publication_id INT,
  followed_at    TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    follow.mask_id          AS mask_id,
    follow.publication_id   AS publication_id,
    follow.created_at       AS followed_at

  FROM
    raw_follows_of(USER_ID) follow

  WHERE
    EXISTS (SELECT * FROM can_read(USER_ID, follow.publicaton_id))
  ;
END
$$ LANGUAGE plpgsql;


-- DOWN
DROP FUNCTION   card_ids_readable_for(INT)          CASCADE;

-- UP
CREATE FUNCTION card_ids_readable_for(IN SN_ID INT)
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


-- DOWN
DROP FUNCTION   last_read(INT)                      CASCADE;

-- UP
CREATE FUNCTION last_read(IN USER_ID INT)
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








-- DOWN
DROP FUNCTION   linked_cards_for(INT)           CASCADE;
-- UP
CREATE FUNCTION linked_cards_for(IN SN_ID INT)
RETURNS TABLE (
  card_id        INT,
  publication_id INT,
  linked_at      TIMESTAMP WITH TIME ZONE
)
AS $$
BEGIN
  RETURN QUERY
  SELECT
  card.id         AS card_id,
  link.b_id       AS publication_id,
  link.created_at AS linked_at
  FROM
    link INNER JOIN card
    ON
    link.type_id = 20 AND
    -- For now:
    --   We make sure only owners of screen_name can
    --   link cards to their screen_name.
    link.owner_id = link.b_id AND
    link.a_id     = card.id AND
    EXISTS ( SELECT * FROM can_read_card(SN_ID, card.id) ) AND
    EXISTS ( SELECT * FROM can_read_card(link.b_id, card.id) )
  ;
END
$$ LANGUAGE plpgsql;


-- DOWN
DROP FUNCTION              can_read(INT, INT)    CASCADE;
-- UP
CREATE OR REPLACE FUNCTION can_read(IN A_ID INT, IN B_ID INT)
RETURNS TABLE ( answer BOOLEAN )
AS $$
BEGIN
  RETURN QUERY
  SELECT true AS answer
  FROM
  screen_name SN
  WHERE
  SN.id = B_ID
  AND (
    -- Can read self:
    A_ID = B_ID
    OR -- Is world readable:
    SN.privacy = 3
    OR -- In list:
    ( SN.privacy = 2 AND EXISTS (SELECT * FROM in_sn_list_of(A_ID, B_ID)) )
  )
  LIMIT 1
  ;
END
$$ LANGUAGE plpgsql;



-- DOWN
DROP FUNCTION              in_sn_list_of(INT, INT)  CASCADE;
-- UP
CREATE OR REPLACE FUNCTION in_sn_list_of(IN AUD_ID INT, IN SN_ID INT)
RETURNS TABLE ( mask_id INT )
AS $$
BEGIN
  RETURN QUERY
  SELECT a_id AS mask_id
  FROM
    link
  WHERE
    type_id = 12 AND
    owner_id = b_id AND
    a_id IN (SELECT id FROM sn_ids_of(AUD_ID))
  LIMIT 1;
END
$$ LANGUAGE plpgsql;


-- DOWN
DROP FUNCTION   follows_of(INT)                 CASCADE;

-- UP
-- 'follows' always provide all screen names, including
-- the ones that can not be seen by SN_ID.
-- This is because the privacy settings of 'card' takes
-- precedence over the privacy setting of the publication/sn.
-- For example: a SN may be entirely private, but some cards
-- can be marked 'world readable bypassing sn privacy'.
CREATE FUNCTION follows_of(IN SN_ID INT)
RETURNS TABLE (
  mask_id        INT,
  publication_id INT,
  created_at     TIMESTAMP WITH TIME ZONE
)
AS $$
BEGIN
  RETURN QUERY
  SELECT
    link.a_id AS mask_id,
    link.b_id AS publication_id,
    link.created_at
  FROM
    link
  WHERE
    type_id = 23
    AND owner_id = a_id -- 'follows' can only be made by sn
    AND owner_id IN (SELECT sn.id FROM sn_ids_of(SN_ID) sn)
  ;
END
$$ LANGUAGE plpgsql;




-- DOWN
DROP FUNCTION   in_card_read_list_of(INT, INT)   CASCADE;
-- UP
CREATE FUNCTION in_card_read_list_of(IN SN_ID INT, IN CARD_ID INT)
RETURNS TABLE ( answer BOOLEAN ) AS $$
DECLARE
  LINK_ALLOW_TO_READ_CARD CONSTANT INT := 24;
BEGIN
  RETURN QUERY
  SELECT
    TRUE AS answer
  FROM
    link
  WHERE
    type_id = LINK_ALLOW_TO_READ_CARD
    AND -- Make sure owner of card granted permission:
    owner_id IN (SELECT owner_id FROM card WHERE card.id = CARD_ID)
    AND
    a_id IN (SELECT id FROM sn_ids_of(SN_ID))
    AND
    b_id = CARD_ID
  LIMIT 1
  ;
END
$$ LANGUAGE plpgsql;

-- DOWN
DROP FUNCTION   can_read_card(INT, INT)          CASCADE;
-- UP
CREATE FUNCTION can_read_card(IN SN_ID INT, IN CARD_ID INT)
RETURNS TABLE ( answer BOOLEAN ) AS $$
BEGIN
  RETURN QUERY
  SELECT
    true AS answer
  FROM
    card
  WHERE
    -- WORLD READable, bypassing SN permission
    card.privacy = 4

    OR
    -- SAME AS SN:
    ( card.privacy = 3 AND EXISTS (SELECT * FROM can_read(SN_ID, card.owner_id)) )

    OR
    -- AUD must be on list allowed card readers to read:
    ( card.privacy = 2 AND EXISTS (SELECT * FROM in_card_read_list_of(SN_ID, card.id)) )
  LIMIT 1
  ;
END
$$ LANGUAGE plpgsql;


-- DOWN
DROP FUNCTION   last_read_of(INT)                      CASCADE;

-- UP
CREATE FUNCTION last_read_of(IN SN_ID INT)
RETURNS TABLE (
  publication_id INT,
  at             TIMESTAMP WITH TIME ZONE
)
AS $$
BEGIN
  RETURN QUERY
  SELECT
    link.b_id       AS publication_id,
    link.created_at AS at
  FROM
    link
  WHERE
    link.type_id  = 22
    AND
    link.owner_id IN (
      SELECT owner_id
      FROM screen_name_read(SN_ID)
      LIMIT 1
    )
    AND link.a_id = link.owner_id
  ;
END
$$ LANGUAGE plpgsql;






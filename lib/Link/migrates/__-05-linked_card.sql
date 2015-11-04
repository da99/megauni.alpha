



-- BOTH
SELECT drop_megauni_func('linked_card');

-- UP
CREATE FUNCTION linked_card(IN SN_ID INT)
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
    link.type_id = type_id('LINK') AND
    -- For now:
    --   We make sure only owners of screen_name can
    --   link cards to their screen_name.
    link.owner_id = link.b_id AND
    link.a_id     = card.id AND
    can_read_card(SN_ID, card.id) AND
    can_read_card(link.b_id, card.id)
  ;
END
$$ LANGUAGE plpgsql;





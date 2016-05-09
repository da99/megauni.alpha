

-- DOWN
DROP VIEW IF EXISTS `last_read`;

-- UP
CREATE OR REPLACE VIEW last_read
AS
  SELECT
    link.b_id       AS publication_id,
    link.created_at AS at
  FROM
    link
  WHERE
    link.type_id  = name_to_type_id('LAST READ AT')
    AND link.a_id = link.owner_id
  ;








-- DOWN
DROP VIEW IF EXISTS `follow_read`;

-- UP
-- 'follow' always provide all screen names, including
-- the ones that can not be seen by SN_ID.
-- This is because the privacy settings of 'card' takes
-- precedence over the privacy setting of the publication/sn.
-- For example: a SN may be entirely private, but some cards
-- can be marked 'world readable bypassing sn privacy'.
CREATE OR REPLACE VIEW `follow`
AS
  SELECT
    link.a_id AS mask_id,
    link.b_id AS publication_id,
    link.created_at
  FROM
    link
  WHERE
    type_id = name_to_type_id('FOLLOW')
    AND owner_id = a_id -- 'follows' can only be made by sn
  ;




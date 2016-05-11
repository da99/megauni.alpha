
-- DOWN
DROP VIEW IF EXISTS `screen_name_allow_audience`;

-- UP
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW `screen_name_allow_audience`
AS
  SELECT
    screen_name.id                   AS screen_name_id,
    screen_name.screen_name          AS screen_name,
    audience_screen_name.owner_id    AS audience_id,
    audience_screen_name.screen_name AS audience_screen_name
  FROM
    link INNER JOIN screen_name
    ON (
      -- ensure screen name owner created link:
      screen_name.id = a_id AND link.owner_id = screen_name.owner_id
      AND
      type_id = name_to_type_id('LIST ONLY')
      AND
      a_type_id = name_to_type_id('SCREEN NAME')
      AND
      b_type_id = name_to_type_id('SCREEN NAME')
    )
    INNER JOIN screen_name AS audience_screen_name ON (
      b_type_id = audience_screen_name.id
    )
;





-- DOWN
DROP VIEW IF EXISTS `screen_name_read`;


-- UP
CREATE OR REPLACE
ALGORITHM = MERGE
SQL SECURITY INVOKER
VIEW `screen_name_read`
AS
  SELECT
    user.id        AS audience_id,
    screen_name.id AS screen_name_id,
    screen_name.screen_name,
    screen_name.nick_name
  FROM
    user
    INNER JOIN screen_name ON (
      screen_name.privacy = name_to_type_id('WORLD READABLE')
      OR
      screen_name.privacy = name_to_type_id('LIST ONLY')
    )
    LEFT JOIN screen_name_allow_audience ON (
      screen_name.privacy = name_to_type_id('LIST ONLY')
      AND
      screen_name.id = screen_name_allow_audience.screen_name_id
      AND
      user.id = screen_name_allow_audience.audience_id
    )
;


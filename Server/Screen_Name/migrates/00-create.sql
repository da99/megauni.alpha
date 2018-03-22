

-- DOWN
DROP TABLE IF EXISTS `screen_name`;

-- UP
CREATE TABLE IF NOT EXISTS `screen_name` (

  -- Primary key:
  id             INTEGER AUTO_INCREMENT PRIMARY KEY,

  -- Refers to "user" id:
  owner_id       INTEGER  NOT NULL,

  -- privacy:
  privacy        SMALLINT NOT NULL,

  -- Refers to "screen_name" id. 0 == top level:
  parent_id      INTEGER  NOT NULL DEFAULT 0,

  -- screen_name:
  screen_name    VARCHAR(30)    NOT NULL,
  CONSTRAINT     UNIQUE KEY `screen_name_unique_idx` (parent_id, screen_name),

  -- nick_name:
  nick_name      VARCHAR(30) NULL,

  -- dates:
  created_at     timestamp,
  trashed_at     timestamp NULL

) engine=TokuDB;


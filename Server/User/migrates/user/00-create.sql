
-- DOWN
DROP TABLE IF EXISTS `user`;

-- UP
CREATE TABLE IF NOT EXISTS `user` (
  id                   INT AUTO_INCREMENT PRIMARY KEY,

  -- Bcrypt-ed string storage requirements: https://mariadb.com/kb/en/mariadb/data-type-storage-requirements/
  pswd_hash            BINARY(60)   NOT NULL,

  created_at           timestamp,
  trashed_at           timestamp NULL
) engine=TokuDB;




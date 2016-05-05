
-- DOWN
DROP TABLE IF EXISTS file_name;

-- UP
CREATE TABLE IF NOT EXISTS file_name (

  id        SMALLINT    AUTO_INCREMENT PRIMARY KEY,
  file_name VARCHAR(30) NOT NULL,

  CONSTRAINT UNIQUE KEY  `file_name_unique_idx`  (file_name)

) engine=TokuDB;




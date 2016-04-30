
CREATE TABLE file_name (

  id SERIAL PRIMARY KEY,
  file_name varchar(30) NOT NULL,

  CONSTRAINT "file_name_unique_idx"
    UNIQUE (file_name)
) engine=TokuDB;



-- DOWN

DROP TABLE IF EXISTS file_name CASCADE;



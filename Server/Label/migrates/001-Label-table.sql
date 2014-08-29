
CREATE TABLE label (

  id        SERIAL PRIMARY KEY,
  owner_id  integer              NOT NULL,
  label     varchar(30)          NOT NULL,
  body      text                 DEFAULT NULL,

  CONSTRAINT "label_unique_idx"
    UNIQUE (owner_id, label)
);



-- DOWN

DROP TABLE IF EXISTS label CASCADE;



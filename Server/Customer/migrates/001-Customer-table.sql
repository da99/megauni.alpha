
CREATE TABLE customer (
  id                   serial PRIMARY KEY,
  perm_level           smallint     NOT NULL DEFAULT 0,
  email                varchar(150)          DEFAULT NULL,
  pswd_hash            varchar(100) NOT NULL,
  log_in_at            date         NOT NULL DEFAULT current_date,
  bad_log_in_count     smallint     NOT NULL DEFAULT 0,
  created_at           timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  trashed_at           timestamp with time zone
);

-- DOWN

DROP TABLE IF EXISTS customer;

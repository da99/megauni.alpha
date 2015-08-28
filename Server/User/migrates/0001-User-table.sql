
CREATE TABLE "user" (
  id                   serial PRIMARY KEY,
  perm_level           smallint     NOT NULL DEFAULT 0,
  pswd_hash            bytea        NOT NULL,
  log_in_at            date         NOT NULL DEFAULT current_date,
  bad_log_in_count     smallint     NOT NULL DEFAULT 0,
  created_at           timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  trashed_at           timestamp with time zone
);

-- DOWN

DROP TABLE IF EXISTS "user";

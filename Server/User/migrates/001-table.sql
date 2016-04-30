
CREATE TABLE "user" (
  id                   serial PRIMARY KEY,
  pswd_hash            bytea        NOT NULL,
  created_at           timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  trashed_at           timestamp with time zone
) engine=TokuDB;


-- DOWN


DROP TABLE    "user"                         CASCADE;



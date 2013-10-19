
CREATE TABLE notify (
  id                SERIAL PRIMARY KEY,
  from_id           integer                  NOT NULL,
  to_id             integer                  NOT NULL,
  body              text                     NOT NULL,
  created_at        timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  updated_at        timestamp with time zone,
  last_read_at      timestamp with time zone
);

CREATE UNIQUE INDEX notify_author_id_idx  ON  chit_chat  ( author_id );

-- DOWN


DROP TABLE notify CASCADE;




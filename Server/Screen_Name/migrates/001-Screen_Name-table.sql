
CREATE TABLE screen_name (
  id             serial   NOT NULL,
  owner_id       integer  NOT NULL,            -- Refers to "user" id
  parent_id      integer  NOT NULL DEFAULT 0,  -- Refers to "screen_name" id
  privacy        smallint NOT NULL DEFAULT 2,
  screen_name    character varying(30) NOT NULL,
  display_name   character varying(30) NOT NULL,
  nick_name      character varying(30) DEFAULT NULL::character varying,
  created_at     timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  trashed_at     timestamp with time zone,

  CONSTRAINT     "screen_name_pkey" PRIMARY KEY (id)
);

CREATE UNIQUE INDEX screen_name_unique_idx ON screen_name (parent_id, screen_name);

-- DOWN


DROP TABLE IF EXISTS screen_name CASCADE;

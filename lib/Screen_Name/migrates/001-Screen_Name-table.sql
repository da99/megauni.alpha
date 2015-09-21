
CREATE TABLE screen_name (
  id             serial   NOT NULL,

  -- Refers to "user" id
  owner_id       integer  NOT NULL,

  -- Refers to "screen_name" id. 0 == top level
  parent_id      integer  NOT NULL DEFAULT 0,

  privacy        smallint                NOT NULL DEFAULT 1,
  CONSTRAINT     privacy_in_menu         CHECK (privacy > 0 AND privacy < 4),

  screen_name    character varying(30)   NOT NULL,
  CONSTRAINT     screen_name_min         CHECK (char_length(screen_name) > 3),
  CONSTRAINT     screen_name_max         CHECK (char_length(screen_name) < 31),
  CONSTRAINT     screen_name_chars       CHECK (screen_name ~ '^[A-Z\d\-\_\.]+$'),

  nick_name      character varying(30)   DEFAULT NULL,

  created_at     timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  trashed_at     timestamp with time zone,

  CONSTRAINT     "screen_name_pkey" PRIMARY KEY (id)
);

CREATE UNIQUE INDEX screen_name_unique_idx ON screen_name (parent_id, screen_name);

-- DOWN


DROP TABLE IF EXISTS screen_name CASCADE;

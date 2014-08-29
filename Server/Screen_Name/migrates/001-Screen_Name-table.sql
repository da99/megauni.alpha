
CREATE TABLE screen_name (
  id             serial   NOT NULL,
  is_sub         boolean  NOT NULL DEFAULT false,
  privacy        smallint NOT NULL DEFAULT 2,
  owner_id       integer  NOT NULL,
  screen_name    character varying(30) NOT NULL,
  display_name   character varying(30) NOT NULL,
  nick_name      character varying(30) DEFAULT NULL::character varying,
  code           text,
  about          text,
  created_at     timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  trashed_at     timestamp with time zone,

  CONSTRAINT     "screen_name_pkey" PRIMARY KEY (id)
);

CREATE UNIQUE INDEX screen_name_unique_idx ON screen_name (is_sub, screen_name)
WHERE is_sub is false;

CREATE UNIQUE INDEX screen_name_sub_unique_idx ON screen_name (is_sub, owner_id, screen_name)
WHERE is_sub is true;

-- DOWN


DROP TABLE IF EXISTS screen_name;

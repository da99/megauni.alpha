
CREATE TABLE screen_name (

  -- Primary key:
  id             serial   NOT NULL,
  CONSTRAINT     "screen_name_pkey" PRIMARY KEY (id),

  -- Refers to "user" id:
  owner_id       integer  NOT NULL,

  -- privacy:
  privacy        smallint NOT NULL DEFAULT 1,

  -- Refers to "screen_name" id. 0 == top level:
  parent_id      integer  NOT NULL DEFAULT 0,

  -- screen_name:
  screen_name    character varying(30)    NOT NULL,
  CONSTRAINT     "screen_name_unique_idx" UNIQUE (parent_id, screen_name),

  -- nick_name:
  nick_name      character varying(30)   DEFAULT NULL,

  -- dates:
  created_at     timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  trashed_at     timestamp with time zone

);


-- DOWN

DROP TABLE screen_name CASCADE;



CREATE TABLE link (

  id          serial            NOT NULL PRIMARY KEY,
  owner_id    integer           NOT NULL,
  type_id     smallint          NOT NULL,
  asker_id    integer           NOT NULL,
  giver_id    integer           NOT NULL,


  created_at        timestamp with time zone NOT NULL DEFAULT timezone('UTC'::text, now()),
  updated_at        timestamp with time zone,

  CONSTRAINT  "link_unique_idx"
    UNIQUE (owner_id, type_id, asker_id, giver_id)

); -- CREATE TABLE link



-- DOWN

DROP TABLE IF EXISTS link CASCADE;


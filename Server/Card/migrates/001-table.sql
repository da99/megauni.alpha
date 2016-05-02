
CREATE TABLE card (

  id                BIGINT AUTO_INCREMENT  PRIMARY KEY,

  -- owner_id:
  -- Refers to screen_name id:
  owner_id          INTEGER               NOT NULL,

  -- privacy:
  -- 1: me_only
  -- 2: same as SN
  -- 3: list of card, ignoring SN list
  -- 4: world readable bypassing screen_name
  privacy        SMALLINT                NOT NULL DEFAULT name_to_type_id('ME ONLY'),

  code           TEXT                    NOT NULL,

  created_at     TIMESTAMP,
  updated_at     TIMESTAMP NULL

) engine=TokuDB;


-- DOWN


DROP TABLE IF EXISTS card CASCADE;


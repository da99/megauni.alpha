
-- DOWN
DROP FUNCTION IF EXISTS type_names () CASCADE;
-- UP
CREATE OR REPLACE FUNCTION type_names()
RETURNS VARCHAR[]
AS $$
DECLARE
  names VARCHAR[] = ARRAY[
    'BLOCK ACCESS TO SCREEN_NAME',  -- # meanie  -> me
    'ALLOW TO LINK',                -- # friend  -> target
    'BLOCK ACCESS TO ALL SCREEN_NAMES',  -- # meanie  -> me
    'ALLOW ACCESS SCREEN_NAME',     -- # friend  -> me
    -- ==============================================

    -- CARDs linked to other stuff: 200++
    'CARD LINKED TO SCREEN_NAME/HOMEPAGE',  -- # sn_id, card.id -> sn.id
    'CARD/COMMENT LINKED TO CARD',          --  # comment -> post
    -- ==============================================

    -- Read/alter CARD: 300+
    'ALLOW TO READ CARD',   --   # sn, sn -> card.id
    -- ==============================================

    -- permissions to read/alter SN
    -- ==============================================

    -- Miscellaneous:
    'LAST READ AT',  --  # owner_id -> owner_id => sn.id
    'FOLLOW'         --  # sn, sn -> target
  ];
BEGIN
  RETURN names;
END
$$
LANGUAGE plpgsql
IMMUTABLE;
-- ========================================================================




-- DOWN
DROP FUNCTION IF EXISTS name_to_smallint (VARCHAR) CASCADE;

-- UP
-- This function has name collisions:
--   'ALLOW IA' == 557
--   'ALLOW Z0' == 557
-- I'm still going to use it. In case a collision is found
--   using a real world example, an exception will have to be
--   written in using CASE or IF/ELSE.
-- Read below for the guard functionality to find collisions while this file
--   is being run.
CREATE OR REPLACE FUNCTION name_to_smallint(IN NAME VARCHAR, OUT NUM SMALLINT)
AS $$
DECLARE
  chars     CHAR[];
  ascii_sum SMALLINT DEFAULT 0;
  order_id  SMALLINT DEFAULT 0;
  pos       SMALLINT DEFAULT 0;
BEGIN
  chars := regexp_split_to_array(NAME, '');

  FOR I IN array_lower(chars, 1)..array_upper(chars, 1) LOOP
    ascii_sum := ascii_sum + (I + ascii(chars[I]));
  END LOOP;

  NUM := ascii_sum;
END
$$
LANGUAGE plpgsql
IMMUTABLE;
-- ========================================================================

-- DOWN
DROP FUNCTION IF EXISTS find_collision_in_name_to_smallint (IN NAMES VARCHAR[]) CASCADE;
-- UP
CREATE OR REPLACE FUNCTION find_collision_in_name_to_smallint(IN NAMES VARCHAR[])
RETURNS BOOLEAN
AS $$
DECLARE
  rec RECORD;
BEGIN

  SELECT
    DISTINCT *
  INTO rec
  FROM (
    SELECT
     id,
     count(id)              OVER by_id AS count,
     string_agg(name, ', ') OVER by_id AS names
    FROM (
      SELECT name_to_smallint(name) AS id, name FROM unnest(type_names()) t(name)
    ) t
    WINDOW by_id AS (PARTITION BY id)
  ) fin
  WHERE count > 1;

  IF FOUND THEN
    RAISE EXCEPTION 'name collision for type ids: %', rec;
  ELSE
    RETURN FALSE;
  END IF;
END
$$
LANGUAGE plpgsql
;
SELECT * FROM find_collision_in_name_to_smallint(type_names());


-- DOWN
DROP FUNCTION IF EXISTS type_name_to_id (VARCHAR) CASCADE;
-- UP
CREATE OR REPLACE FUNCTION type_name_to_id(IN NAME VARCHAR, OUT TYPE_ID SMALLINT)
AS $$
BEGIN
  IF NOT NAME = ANY(type_names()) THEN
    RAISE EXCEPTION 'programmer error: NAME not found in type_names(): %', NAME;
  END IF;

  TYPE_ID := name_to_smallint(NAME);
END
$$
LANGUAGE plpgsql
IMMUTABLE;

-- ========================================================================


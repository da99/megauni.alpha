

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
CREATE OR REPLACE FUNCTION name_to_smallint(IN NAME VARCHAR)
RETURNS SMALLINT
AS $$
BEGIN
  CASE NAME

  WHEN 'ME_ONLY'                             THEN RETURN 584;
  WHEN 'LIST_ONLY'                           THEN RETURN 769;
  WHEN 'WORLD READABLE'                      THEN RETURN 1043;
  WHEN 'SAME AS OWNER'                       THEN RETURN 915;
  WHEN 'LIST AND OWNER LIST'                 THEN RETURN 1409;

  WHEN 'BLOCK ACCESS TO SCREEN_NAME'         THEN RETURN 2143; -- # meanie  -> me
  WHEN 'ALLOW TO LINK'                       THEN RETURN 926;  -- # friend  -> target
  WHEN 'BLOCK ACCESS TO ALL SCREEN_NAMES'    THEN RETURN 2588; -- # meanie  -> me
  WHEN 'ALLOW ACCESS SCREEN_NAME'            THEN RETURN 1925; -- # friend  -> me

  WHEN 'CARD LINKED TO SCREEN_NAME/HOMEPAGE' THEN RETURN 2940; -- # sn_id, card.id -> sn.id
  WHEN 'CARD/COMMENT LINKED TO CARD'         THEN RETURN 2095; --  # comment -> post
  WHEN 'ALLOW TO READ CARD'                  THEN RETURN 1265; --   # sn, sn -> card.id

  WHEN 'LAST READ AT'                        THEN RETURN 807;  --  # owner_id -> owner_id => sn.id
  WHEN 'FOLLOW'                              THEN RETURN 482;  --  # sn, sn -> target
    -- ==============================================

  ELSE
    RAISE EXCEPTION 'programmer_error: name not found: %', NAME;
  END CASE;
END
$$
LANGUAGE plpgsql
IMMUTABLE;
--  CREATE OR REPLACE FUNCTION name_to_smallint(IN NAME VARCHAR, OUT NUM SMALLINT)
--  AS $$
--  DECLARE
  --  chars     CHAR[];
  --  ascii_sum SMALLINT DEFAULT 0;
  --  order_id  SMALLINT DEFAULT 0;
  --  pos       SMALLINT DEFAULT 0;
--  BEGIN
  --  chars := regexp_split_to_array(NAME, '');

  --  FOR I IN array_lower(chars, 1)..array_upper(chars, 1) LOOP
    --  ascii_sum := ascii_sum + (I + ascii(chars[I]));
  --  END LOOP;

  --  NUM := ascii_sum;
--  END
--  $$
--  LANGUAGE plpgsql
--  IMMUTABLE;
-- ========================================================================






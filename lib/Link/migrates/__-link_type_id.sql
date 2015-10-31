
-- DOWN
DROP FUNCTION IF EXISTS    name_to_type_ids (VARCHAR) CASCADE;

-- UP
CREATE OR REPLACE FUNCTION name_to_type_ids (IN NAME VARCHAR)
RETURNS VARCHAR[]
AS $$
DECLARE
  SPLITS  VARCHAR[];
  TRIMMED VARCHAR;
BEGIN
  SPLITS := regexp_split_to_array(NAME, '\||,');

  FOR i IN array_lower(SPLITS, 1)..array_upper(SPLITS, 1) LOOP
    TRIMMED := trim(BOTH FROM SPLITS[i]);
    IF i = 1 THEN
      SPLITS[i] := name_to_link_type_id(TRIMMED);
    ELSE
      SPLITS[i] := name_to_type_id(TRIMMED);
    END IF;
  END LOOP;

  RETURN SPLITS;
END
$$ LANGUAGE plpgsql IMMUTABLE;


-- DOWN
DROP FUNCTION IF EXISTS    name_to_type_id (VARCHAR) CASCADE;

-- UP
CREATE OR REPLACE FUNCTION name_to_type_id (IN NAME VARCHAR)
RETURNS SMALLINT
AS $$
DECLARE
BEGIN

  CASE NAME
  WHEN 'USER'                                THEN RETURN 1;
  WHEN 'SCREEN_NAME', 'SN'                   THEN RETURN 2;
  WHEN 'CARD'                                THEN RETURN 3;
  ELSE
    RAISE EXCEPTION 'programmer_error: name for type_id not found: %', NAME;
  END CASE;

END
$$
LANGUAGE plpgsql
IMMUTABLE;


-- DOWN
DROP FUNCTION IF EXISTS    name_to_link_type_id (VARCHAR) CASCADE;

-- UP
CREATE OR REPLACE FUNCTION name_to_link_type_id (IN NAME VARCHAR)
RETURNS SMALLINT
AS $$
DECLARE
BEGIN
  CASE NAME

  WHEN 'ME_ONLY'                             THEN RETURN 10;
  WHEN 'LIST_ONLY'                           THEN RETURN 11;
  WHEN 'WORLD READABLE'                      THEN RETURN 12;
  WHEN 'SAME AS OWNER'                       THEN RETURN 13;
  WHEN 'LIST AND OWNER LIST'                 THEN RETURN 14;

  WHEN 'BLOCK'                               THEN RETURN 20; -- # meanie  -> me
  WHEN 'BLOCK ALL'                           THEN RETURN 21; -- # meanie  -> me

  WHEN 'ALLOW TO CREATE'                     THEN RETURN 30;  -- # friend  -> target
  WHEN 'ALLOW TO READ'                       THEN RETURN 31;  -- # friend  -> target
  WHEN 'ALLOW TO READ'                       THEN RETURN 32;  -- # friend  -> target
  WHEN 'ALLOW TO LINK'                       THEN RETURN 33;  -- # friend  -> target

  WHEN 'LINK'                                THEN RETURN 40; -- # sn_id, card.id -> sn.id

  WHEN 'LAST READ AT'                        THEN RETURN 90;  --  # owner_id -> owner_id => sn.id
  WHEN 'FOLLOW'                              THEN RETURN 91;  --  # sn, sn -> target
    -- ==============================================

  ELSE
    RAISE EXCEPTION 'programmer_error: name link_type_id not found: %', NAME;
  END CASE;
END
$$
LANGUAGE plpgsql
IMMUTABLE;







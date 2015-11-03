
-- BOTH
SELECT drop_megauni_func('name_to_type_ids');

-- UP
CREATE OR REPLACE FUNCTION name_to_type_ids (IN NAME VARCHAR)
RETURNS SMALLINT[]
AS $$
DECLARE
  SPLITS     VARCHAR[];
  IDS        SMALLINT[];
  TRIMMED    VARCHAR;
BEGIN
  CASE NAME
    WHEN 'LINK | CARD, SN', 'LINK | CARD, SCREEN_NAME' THEN
      NAME := 'LINK | SN, CARD, SN';
    ELSE
      NAME := NAME;
  END CASE;

  SPLITS     := regexp_split_to_array(NAME, '\||,');
  FOR i IN array_lower(SPLITS, 1)..array_upper(SPLITS, 1) LOOP
    TRIMMED := trim(BOTH FROM SPLITS[i]);
    IDS[i] = name_to_type_id(TRIMMED);
  END LOOP;

  RETURN IDS;
END
$$ LANGUAGE plpgsql IMMUTABLE;


-- BOTH
SELECT drop_megauni_func('name_to_type_id');

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
  WHEN 'ME ONLY'                             THEN RETURN 10;
  WHEN 'LIST ONLY'                           THEN RETURN 11;
  WHEN 'WORLD READABLE'                      THEN RETURN 12;
  WHEN 'SAME AS OWNER'                       THEN RETURN 13;
  WHEN 'LIST AND OWNER LIST'                 THEN RETURN 14;

  WHEN 'BLOCK'                               THEN RETURN 20; -- # meanie  -> me
  WHEN 'BLOCK ALL SCREEN_NAMES'              THEN RETURN 21; -- # meanie  -> me

  WHEN 'ALLOW TO CREATE'                     THEN RETURN 31;  -- # friend  -> target
  WHEN 'ALLOW TO READ'                       THEN RETURN 32;  -- # friend  -> target

  WHEN 'LINK'                                THEN RETURN 40; -- # sn_id, card.id -> sn.id

  WHEN 'LAST READ AT'                        THEN RETURN 90;  --  # owner_id -> owner_id => sn.id
  WHEN 'FOLLOW'                              THEN RETURN 91;  --  # sn, sn -> target
  ELSE
    RAISE EXCEPTION 'programmer_error: name for type_id not found: %', NAME;
  END CASE;

END
$$
LANGUAGE plpgsql
IMMUTABLE;





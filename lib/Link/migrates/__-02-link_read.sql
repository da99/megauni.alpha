
-- BOTH
SELECT drop_megauni_func('link_read');

-- UP
CREATE OR REPLACE FUNCTION link_read (
  IN USER_ID   INT,
  IN TYPE_NAME VARCHAR,
  IN RAW_A     VARCHAR,
  IN RAW_B     VARCHAR
) RETURNS SETOF link AS $$
DECLARE
  IDS SMALLINT[];
  SN_TYPE_ID SMALLINT := name_to_type_id('SCREEN_NAME');
BEGIN
  IDS := name_to_type_ids(TYPE_NAME);
  IF IDS[3] = SN_TYPE_ID AND IDS[4] = SN_TYPE_ID THEN
    RETURN QUERY
      SELECT *
      FROM link_read(USER_ID, TYPE_NAME, screen_name_id(RAW_A), screen_name_id(RAW_B));
  ELSE
    RAISE EXCEPTION 'programmer_error: not implemented';
  END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION link_read (
  IN USER_ID   INT,
  IN TYPE_NAME VARCHAR,
  IN A_ID      INT,
  IN RAW_SN    VARCHAR
) RETURNS SETOF link AS $$
DECLARE
  IDS SMALLINT[];
BEGIN
  IDS := name_to_type_ids(TYPE_NAME);
  CASE IDS[4]
  WHEN name_to_type_id('SCREEN_NAME') THEN
    RETURN QUERY
      SELECT *
      FROM link_read(USER_ID, TYPE_NAME, A_ID, screen_name_id(RAW_SN));
  ELSE
    RAISE EXCEPTION 'programmer_error: not implemented';
  END CASE;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION link_read (
  IN USER_ID   INT,
  IN TYPE_NAME VARCHAR,
  IN RAW_AID   INT,
  IN RAW_BID   INT
) RETURNS SETOF link AS $$
DECLARE
  IDS SMALLINT[];
BEGIN
  IDS := name_to_type_ids(TYPE_NAME);

  RETURN QUERY
  SELECT *
  FROM link
  WHERE
  type_id       = IDS[1] AND
  owner_type_id = IDS[2] AND
  a_type_id     = IDS[3] AND
  b_type_id     = IDS[4] AND

  link.a_id = RAW_AID AND link.b_id = RAW_BID;

END
$$ LANGUAGE plpgsql;

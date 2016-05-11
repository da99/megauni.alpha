
-- DOWN
SELECT drop_megauni_func('screen_name_canonize');

-- UP
CREATE OR REPLACE FUNCTION screen_name_canonize(inout sn varchar)
AS $$
  BEGIN
    -- screen_name
    IF sn IS NULL THEN
      RAISE EXCEPTION 'programmer_error: NULL value';
    END IF;
    sn := upper(sn);
    sn := regexp_replace(sn, '^\@|[\s[:cntrl:]]+', '', 'ig');
  END
$$
LANGUAGE plpgsql
IMMUTABLE
;





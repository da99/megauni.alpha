
CREATE OR REPLACE FUNCTION screen_name_canonize(inout sn varchar)
AS $$
  BEGIN
    -- screen_name
    sn := upper(sn);
    sn := regexp_replace(sn, '^\@|[\s[:cntrl:]]+', '');
  END
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

-- DOWN

DROP FUNCTION IF EXISTS screen_name_canonize (varchar)
  CASCADE;




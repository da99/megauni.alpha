
-- FROM:
-- http://stackoverflow.com/questions/16632117/get-all-procedural-user-defined-functions
-- http://www.postgresonline.com/journal/archives/74-How-to-delete-many-functions.html

-- DOWN

-- DROP all custom functions.
-- This ensures there are no forgotten funcs
--   being used by other custom functions/queries.
-- In other words: We want a clean slate for development/testing.
DO $$
  DECLARE
    r RECORD;
  BEGIN
    FOR r IN SELECT drop_func_sql FROM megauni_funcs() LOOP
      EXECUTE r.drop_func_sql;
    END LOOP;
  END
  $$ LANGUAGE plpgsql;

-- BOTH
DROP FUNCTION IF EXISTS drop_megauni_func_and_void(VARCHAR);
DROP FUNCTION IF EXISTS drop_megauni_func (VARCHAR);
DROP FUNCTION IF EXISTS megauni_funcs     ();

-- UP
CREATE FUNCTION megauni_funcs()
RETURNS TABLE(oid oid, proname name, inputs text, drop_func_sql text)
AS $$
BEGIN
  RETURN QUERY
  SELECT
  pp.oid AS oid,
  pp.proname,
  oidvectortypes(pp.proargtypes) AS inputs,
  CONCAT(
    'DROP FUNCTION IF EXISTS ',
    pp.proname,
    '(', oidvectortypes(pp.proargtypes), ');'
  ) AS drop_func_sql
  FROM
  pg_proc pp
  inner join pg_namespace pn on (pp.pronamespace = pn.oid)
  inner join pg_language pl on (pp.prolang = pl.oid)
  WHERE
  pl.lanname NOT IN ('c','internal')
  AND pn.nspname NOT LIKE 'pg_%'
  AND pn.nspname <> 'pg_catalog'
  -- Let's avoid trigger functions:
  AND pn.nspname <> 'information_schema'
  AND pp.oid NOT IN (SELECT  tgrelid FROM pg_trigger)
  AND pp.oid NOT IN (SELECT  tgfoid  FROM pg_trigger)
;
END
$$ LANGUAGE plpgsql;


CREATE FUNCTION drop_megauni_func(IN TARGET_NAME VARCHAR)
RETURNS TABLE(name TEXT, inputs TEXT, sql TEXT)
AS $$
DECLARE
  names  NAME[];
  inputs TEXT[];
  sqls   TEXT[];
  r      RECORD;
BEGIN
  FOR r IN
    SELECT * FROM megauni_funcs() mf WHERE mf.proname = TARGET_NAME
  LOOP
    EXECUTE r.drop_func_sql;
    names  := array_append(names, r.proname);
    inputs := array_append(inputs, r.inputs);
    sqls   := array_append(sqls, r.drop_func_sql);

  END LOOP;
  RETURN QUERY
  SELECT *
  FROM
    unnest(
      names::TEXT[],
      inputs::TEXT[],
      sqls::TEXT[]
    )  as t(name, inputs, sql)
   ;
END
$$ LANGUAGE plpgsql;


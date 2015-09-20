

CREATE FUNCTION screen_name_before_insert()
RETURNS trigger AS $$
  BEGIN
    IF NEW.privacy IS NOT NULL AND NEW.privacy NOT IN ('1,2,3}'::int[])) THEN
      RAISE EXCEPTION 'PROGRAMMER ERROR: Privacy can only be: 1, 2, 3';
    END IF;
    RETURN NEW;
  END
$$ LANGUAGE plpgsql

-- DOWN

DROP FUNCTION IF EXISTS screen_name_before_insert () CASCADE;

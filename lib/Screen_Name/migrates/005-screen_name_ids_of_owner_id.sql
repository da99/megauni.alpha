

CREATE FUNCTION screen_name_ids_of_owner_id(
  IN  user_id         INT
) RETURNS TABLE (id int) AS $$
  BEGIN
    RETURN QUERY
    SELECT "screen_name".id
    FROM "screen_name"
    WHERE
      parent_id = 0
      AND
      owner_id = user_id;
  END

$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION screen_name_ids_of_owner_id ( INT ) CASCADE;

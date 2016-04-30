


-- BOTH
DROP PROCEDURE IF EXISTS link_insert;

-- UP
DELIMITER //

CREATE PROCEDURE link_insert (
  IN  USER_ID        INT,
  IN  TYPE_NAME      VARCHAR(255),
  IN  A_SCREEN_NAME  VARCHAR(255),
  IN  B_SCREEN_NAME  VARCHAR(255),
  OUT LINK_ID        INT
)
BEGIN
  DECLARE IDS SMALLINT ARRAY[4];
  -- SELECT name_to_type_ids(TYPE_NAME);

  CASE IDS
  WHEN name_to_type_ids('FOLLOW | SCREEN_NAME, SCREEN_NAME') THEN

    INSERT INTO link (
      type_id,
      owner_type_id, owner_id,
      a_type_id,     a_id,
      b_type_id,     b_id
    )
    VALUES (
      -- TYPE_ID
      IDS[1],

      -- OWNER_ID = A_ID
      IDS[2], screen_name_id_if_owns_or_fail(USER_ID, A_SCREEN_NAME),

      -- A_ID
      IDS[3], screen_name_id_if_owns_or_fail(USER_ID, A_SCREEN_NAME),

      -- B_ID
      IDS[4], screen_name_id_or_fail(USER_ID, B_SCREEN_NAME)
    ) ;

  WHEN name_to_type_ids('LINK | CARD, SCREEN_NAME') THEN

    INSERT INTO link (
      type_id,
      owner_type_id, owner_id,
      a_type_id,     a_id,
      b_type_id,     b_id
    )
    VALUES (
      IDS[1],

      IDS[2], screen_name_id_if_owns_or_fail(USER_ID, SCREEN_NAME),
      IDS[3], card_id_or_fail(USER_ID, A_ID),
      IDS[4], screen_name_id_if_owns_or_fail(USER_ID, SCREEN_NAME)
    ) RETURNING link.id;

  ELSE
    RAISE EXCEPTION 'programmer_error: unknown link_insert type: %', TYPE_NAME;

  END CASE;

  SELECT id AS LAST_INSERT_ID() INTO LINK_ID;
END //


CREATE PROCEDURE link_insert (
  IN  USER_ID      INT,
  IN  TYPE_NAME    VARCHAR,
  IN  A_ID         INT,
  IN  SCREEN_NAME  VARCHAR
  OUT LINK_ID      INT
)
BEGIN
  DECLARE IDS SMALLINT[];
  IDS := name_to_type_ids(TYPE_NAME);

  CASE IDS
  WHEN name_to_type_ids('LINK | CARD, SCREEN_NAME') THEN

    INSERT INTO link (
      type_id,
      owner_type_id, owner_id,
      a_type_id,     a_id,
      b_type_id,     b_id
    )
    VALUES (
      IDS[1],

      IDS[2], screen_name_id_if_owns_or_fail(USER_ID, SCREEN_NAME),
      IDS[3], card_id_or_fail(USER_ID, A_ID),
      IDS[4], screen_name_id_if_owns_or_fail(USER_ID, SCREEN_NAME)
    ) RETURNING link.id;

  ELSE
    RAISE EXCEPTION 'programmer_error: unknown link_insert type: %', TYPE_NAME;

  END CASE;

  SELECT id AS LAST_INSERT_ID() INTO LINK_ID;
END //

DELIMITER ;


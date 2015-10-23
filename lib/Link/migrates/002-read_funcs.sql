

-- Results:
--   mask id | mask sn (aud alias) |  pub id  | pub sn | follow created at
follow(user_id) AS (

  SELECT
    mask.id                 AS mask_id,
    mask.screen_name        AS mask_screen_name,
    publication.id          AS publication_id,
    publication.screen_name AS publication_screen_name,
    follow.created_at       AS created_at

  FROM
    link        AS follow,
    screen_name AS mask,
    screen_name AS publication

  WHERE
    -- find the right links -----------------
    follow.type_id  = 23
    AND follow.owner_id IN (
      SELECT id
      FROM screen_name_read(AUDIENCE_USER_ID)
    )
    AND follow.owner_id = follow.a_id

    -- join the screen_names ----------------
    AND mask.id        = follow.a_id
    AND publication.id = follow.b_id

) -- follow



-- Results:
--   mask sn (aud alias) |  pub id  | pub sn | follow created at
allowed_follow(user_id) AS (
  SELECT *
  FROM
    follow(AUDIENCE_ID) AS follow
  WHERE
    publication_id NOT IN (blocked by aud)
    AND mask_id NOT IN (blocked by publication user/owner)
) -- allowed_follow


last_card AS (
  SELECT
    publication INFO,
    card.id,
    MAX(card.created_at) AS created_at
  FROM
    link,
    card,
    screen_name AS publication
  WHERE
    link.type_id = 20
    AND link.a_id = card.id
    AND link.b_id = publication.id
  GROUP BY publication.id
)


allowed_last_card(AUDIENCE_ID) AS (
  SELECT *
  FROM last_card
  WHERE
    card (owner NOT blocked by pub owner) AND
    card (owner NOT blocked by aud/owner) AND

    card (owner has not blocked pub/owner) AND
    card (owner has not blocked aud/owner) AND
    card.created_at > LAST_READ.at
)


last_read AS (
  SELECT
    link_reads_at.a_id       AS owner_id,
    link_reads_at.b_id       AS publication_id,
    link_reads_at.created_at AS last_at
  FROM
    link         AS link_reads_at
  WHERE
    link_cards.type_id  = 22
    AND
    link.owner_id IN (
      SELECT owner_id
      FROM screen_name_read(AUDIENCE_USER_ID)
    )
    AND link.a_id = link.owner_id
) -- last_read


news AS (
  -- JOIN cards through "link" table
  link_cards.type_id  = 20
  AND link_cards.owner_id = following.publication_id
  AND link_cards.a_id     = cards.id
  AND link_cards.b_id     = following.publication_id
  -- ---------------------------------------------------------------------

  --  filter out posts viewer can't read.
  --    banned by viewer
  --    banned/protected by card author (viewer, publication)
  --    banned/protected by publication
  -- ----------------------------------------------------------------------

  -- ----------------------------------------------------------------------
  -- SN owner allows AUDIENCE to see it
  AND ( AUDIENCE_USER_ID (IS ALLOWED) AND (NOT BLOCKED) PINNER, PUB, AUTHOR )

  -- SN owner gave permission, and not blocked, PINNER to card
  AND ( PINNER IS ALLOWED NOT BLOCKED TO CARD )
  AND ( AUTHOR IS ALLOWED NOT BLOCKED BY PINNER, PUB )

  -- POST allowed to be seen by: SN owner, PINNER owner, AUDIENCE
  AND ( CARD     PRIVACY SETTINGS for PINNER, PUB, AUDIENCE_USER_ID )
  -- ----------------------------------------------------------------------

  --  ONLY include latest card published after viewer read the publication.
  AND link_cards.a_id = last_readings.publication_id
  AND cards.created_at >= readings.last_at
  --  ---------------------------------------------------------------------
)




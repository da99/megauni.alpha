
-- POST
SELECT
  computer.id               AS post_id,
  computer.owner_id         AS post_author_owner_id,
  computer.code             AS post_code,

  link.created_at           AS post_posted_at

  link.owner_id             AS post_author_id,
  pub.id                    AS pub_id,
  pub.screen_name           AS pub_name,
  pub.owner_id              AS pub_owner_id

FROM

  link,
  screen_name AS pinner,
  screen_name AS pub,
  computer    AS post,
  screen_name AS author

WHERE
      link.type_id  = :POST_TYPE_ID
  AND link.owner_id = pinner.id AND link.owner_id = post.owner_id
  AND link.asker_id = post.id
  AND link.giver_id = pub.id
  AND post.owner_id = author.id

  -- SN owner allows AUDIENCE to see it
    AND ( :AUDIENCE_OWNER_ID (IS ALLOWED) AND (NOT BLOCKED) PINNER, PUB, AUTHOR )

  -- SN owner gave permission, and not blocked, PINNER to post
    AND ( PINNER IS ALLOWED NOT BLOCKED TO POST )
    AND ( AUTHOR IS ALLOWED NOT BLOCKED BY PINNER, PUB )

  -- POST allowed to be seen by: SN owner, PINNER owner, AUDIENCE
    AND ( COMPUTER PRIVACY SETTINGS for PINNER, PUB, :AUDIENCE_OWNER_ID )


ORDER BY created_at DESC




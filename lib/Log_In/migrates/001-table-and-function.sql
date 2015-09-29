
-- Worse case scenario:
--   An automated script is created by evil doer to
--   lock every screen name for 24 hours by logging in
--   w/wrong password.
--
-- Solution:
--   It's mediocre but should lessened the disaster:
--     1) Lock out any IP address w/4 lock outed screen names.
--     2) Lock out any Screen_Name w/ 4 failed log-in attempts.
--
-- Reasoning:
--     1) Screen_Name is used because people might mis-type
--        one of their screen names (over and over again).
--     2) Someone else might accidentally lock a stranger out.
--        If password is correct AND fail_count <= 4,
--        RESET log_in for all screen_names belonging to User.

CREATE TABLE log_in (
  ip                   inet         NOT NULL primary key,
  log_in_at            timestamp    NOT NULL DEFAULT timezone('UTC'::text, now()),
  fail_count           smallint     NOT NULL DEFAULT 1,
  screen_name_id       int          NOT NULL,
  CONSTRAINT           "log_in_unique_idx" UNIQUE (ip, screen_name_id)
);

CREATE OR REPLACE FUNCTION log_in_upsert(
  IN  raw_ip          inet,
  IN  raw_screen_name varchar,
  IN  raw_pswd_hash   bytea,
  OUT user_id         int
)
AS $$
  DECLARE
    log_in_record  RECORD;
    sn_record      RECORD;
    sn_id          int;
    ip_locked_out  boolean;
  BEGIN

    -- SEE IF ip is locked out
    SELECT sum(ip) AS locked_out_screen_names
    FROM log_in
    WHERE
      ip = raw_ip
      AND
      fail_count > 3
      AND
      log_in_at > TODAY_0 AND log_in_at TODAY_1
    HAVING locked_out_screen_names > 3
    ;

    IF FOUND THEN
      raise 'log_in: ip locked out for 24 hours';
    END IF;

    -- Get screen name id:
    SELECT id
    INTO sn_record
    FROM screen_name
    WHERE
      screen_name = screen_name_canonize(raw_screen_name);

    IF NOT FOUND THEN
      raise 'log_in: screen name not found';
    END IF;

    -- SEE IF screen_name is locked out
    SELECT *
    FROM log_in
    WHERE
      screen_name_id = sn_record.id
      AND
      fail_count > 3
      AND
      log_in_at > TODAY_0 && log_in_at < TODAY_1;

    IF FOUND THEN
      raise 'log_in: screen name is locked out';
    END IF;


    -- SEE IF password matches:
    SELECT id
    FROM "user"
    WHERE
      pswd_hash = raw_pswd_hash;

    IF FOUND THEN
      user_id := sn_record.owner_id;
      RETURN user_id;
    END IF;

    -- Log failed log in attempt:
    UPDATE log_in
    SET
      fail_count = fail_count + 1,
      log_in_at  = timezone('UTC'::text, now())
    WHERE
      ip = raw_ip
      AND
      screen_name_id = sn_record.id
    RETURNING *
    ;

    IF NOT FOUND THEN
      INSERT INTO log_in (ip,     screen_name_id)
      VALUES             (raw_ip, sn_record.id)
    END IF
    ;

  END
$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION log_in_upsert (inet, varchar, bytea) CASCADE;
DROP TABLE IF EXISTS log_in CASCADE;


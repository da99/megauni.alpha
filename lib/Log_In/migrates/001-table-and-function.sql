
-- Worse case scenario:
--   An automated script is created by evil doer to
--   lock every screen name for 24 hours by logging in
--   w/wrong password.
--
-- Solution:
--   It's mediocre but should lessened the disaster:
--     1) Lock out any IP address w/4 lock outed screen names.
--     2) Lock out any Screen_Name w/ 6+ failed log-in attempts.
--
-- Reasoning:
--     1) Screen_Name is used because people might mis-type
--        one of their screen names (over and over again).
--     2) Someone else might accidentally lock a stranger out.
--        If password is correct AND fail_count <= 4,
--        RESET log_in for all screen_names belonging to User.

CREATE TABLE log_in (
  ip                   inet         NOT NULL primary key,
  at                   timestamp    NOT NULL DEFAULT timezone('UTC'::text, now()),
  fail_count           smallint     NOT NULL DEFAULT 1,
  screen_name_id       int          NOT NULL,
  CONSTRAINT           "log_in_unique_idx" UNIQUE (ip, screen_name_id)
);

CREATE INDEX log_in_screen_name_id_idx
ON log_in (screen_name_id)
WHERE screen_name_id > 0;

CREATE FUNCTION log_in_attempt(
  -- Workaround: Elixir has trouble encoding "inet", so we use varchar for raw_ip.
  IN  raw_ip          VARCHAR,
  IN  sn_id           INT,
  IN  user_id         INT,
  IN  pass_match      BOOLEAN,
  OUT has_pass        BOOLEAN,
  OUT reason          VARCHAR
)
AS $$
  DECLARE
    log_in_record  RECORD;
    MAX_FAIL_COUNT SMALLINT;
    IP_FAIL_COUNT  SMALLINT;
    NOW_UTC        TIMESTAMP;
    START_DATE     TIMESTAMP;
    END_DATE       TIMESTAMP;
  BEGIN

    MAX_FAIL_COUNT := 4;
    IP_FAIL_COUNT  := 4;
    NOW_UTC    := timezone('UTC'::text, now());
    START_DATE := (NOW_UTC - '1 day'::interval);
    END_DATE   := (NOW_UTC + '1 day'::interval);

    -- SEE IF ip is locked out
    SELECT count(ip) AS locked_out_screen_names
    INTO log_in_record
    FROM log_in
    WHERE
      ip = raw_ip::inet
      AND
      fail_count >= MAX_FAIL_COUNT
      AND
      at > START_DATE AND at < END_DATE
    HAVING count(ip) >= IP_FAIL_COUNT
    ;

    IF FOUND THEN
      -- FAIL
      has_pass := false;
      reason   := 'log_in: ip locked out for 24 hours';
      RETURN;
    END IF;

    -- Get screen name id:
    IF sn_id IS NULL THEN
      -- FAIL
      has_pass := false;
      reason   := 'log_in: screen_name not found';
      RETURN;
    END IF;

    -- SEE IF screen_name is locked out
    SELECT sum(fail_count) AS total_fail_count
    INTO log_in_record
    FROM log_in
    WHERE
      screen_name_id = sn_id
      AND
      at > START_DATE AND at < END_DATE
    HAVING sum(fail_count) >= MAX_FAIL_COUNT
    ;

    IF FOUND THEN
      -- FAIL
      has_pass := false;
      reason   := 'log_in: screen_name locked out';
      RETURN;
    END IF;

    -- Log failed log in attempt:
    IF NOT pass_match THEN
      UPDATE log_in
      SET
        fail_count = fail_count + 1,
        at         = timezone('UTC'::text, now())
      WHERE
        ip = raw_ip::inet
        AND
        screen_name_id = sn_id;

      IF NOT FOUND THEN
        INSERT INTO log_in (ip,           screen_name_id)
        VALUES             (raw_ip::inet, sn_id);
      END IF;

      --- FAIL
      has_pass := FALSE;
      reason   := 'log_in: password no match';
      RETURN;
    END IF;

    DELETE FROM log_in
    WHERE screen_name_id IN (
      SELECT id
      FROM screen_name_ids_for_owner_id(user_id)
    );

    has_pass := TRUE;
    reason   := NULL;
  END
$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION log_in_attempt (varchar, int, int, boolean) CASCADE;
DROP INDEX    log_in_screen_name_id_idx CASCADE;
DROP TABLE    log_in CASCADE;



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
  IN  raw_ip          varchar,
  IN  sn_id           int,
  IN  user_id         int,
  IN  pass_match      boolean,
  OUT has_pass        boolean
)
AS $$
  DECLARE
    ip_locked_out  boolean;
    start_date     timestamp;
    end_date       timestamp;
  BEGIN

    start_date := (current_date - '1 day'::interval);
    end_date   := (current_date + '1 day'::interval);

    -- SEE IF ip is locked out
    PERFORM count(ip) AS locked_out_screen_names
    FROM log_in
    WHERE
      ip = raw_ip::inet
      AND
      fail_count > 3
      AND
      at > start_date AND at < end_date
    HAVING count(ip) > 3
    ;

    IF FOUND THEN
      RAISE 'log_in: ip locked out for 24 hours';
    END IF;

    -- Get screen name id:
    IF sn_id IS NULL THEN
      RAISE 'log_in: screen name not found';
    END IF;

    -- SEE IF screen_name is locked out
    PERFORM count(fail_count) AS total_fail_count
    FROM log_in
    WHERE
      screen_name_id = sn_id
      AND
      at > start_date AND at < end_date
    HAVING count(fail_count) > 5
    ;

    IF FOUND THEN
      RAISE 'log_in: screen name locked out';
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

      raise 'log_in: password no match';
    END IF;

    has_pass := TRUE;
  END
$$ LANGUAGE plpgsql;

-- DOWN

DROP FUNCTION log_in_attempt (varchar, int, int, boolean) CASCADE;
DROP INDEX    log_in_screen_name_id_idx CASCADE;
DROP TABLE    log_in CASCADE;


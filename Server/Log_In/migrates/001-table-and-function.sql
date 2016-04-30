
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

-- DOWN
DROP TABLE    log_in CASCADE;

-- UP
CREATE TABLE log_in (
  ip                   inet         NOT NULL,
  at                   timestamp    NOT NULL DEFAULT timezone('UTC'::text, now()),
  fail_count           smallint     NOT NULL DEFAULT 1,
  screen_name_id       int          NOT NULL,
  CONSTRAINT           "log_in_unique_idx" UNIQUE (ip, screen_name_id)
) engine=TokuDB;

-- UP
CREATE INDEX log_in_screen_name_id_idx
ON log_in (screen_name_id)
WHERE screen_name_id > 0;

CREATE INDEX log_in_ip_idx
ON log_in (ip);




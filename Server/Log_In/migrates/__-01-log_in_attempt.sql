
-- DOWN

SELECT drop_megauni_func('log_in_attempt');

-- UP
--  We don't use "raise" here because
--  it would prevent inserting
--  bad attempts (ie rollback the transaction).
--  So instead we return a row [{has_pass, reason}]
--  and the application will standardize it into
--  {has_pass: ..., reason: ...}
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
    ip_inet        INET;
  BEGIN

    MAX_FAIL_COUNT := 4;
    IP_FAIL_COUNT  := 4;
    NOW_UTC        := timezone('UTC'::text, now());
    START_DATE     := (NOW_UTC - '1 day'::interval);
    END_DATE       := (NOW_UTC + '1 day'::interval);
    ip_inet        := raw_ip::inet;

    -- SEE IF ip is locked out
    SELECT count(ip) AS locked_out_screen_names
    INTO log_in_record
    FROM log_in
    WHERE
      ip = ip_inet
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
        ip = ip_inet
        AND
        screen_name_id = sn_id;

      IF NOT FOUND THEN
        INSERT INTO log_in (ip,      screen_name_id)
        VALUES             (ip_inet, sn_id);
      END IF;

      --- FAIL
      has_pass := FALSE;
      reason   := 'log_in: password no match';
      RETURN;
    END IF;

    DELETE FROM log_in
    WHERE screen_name_id IN (
      SELECT id
      FROM screen_name_ids(user_id)
    );

    has_pass := TRUE;
    reason   := NULL;
  END
$$ LANGUAGE plpgsql;




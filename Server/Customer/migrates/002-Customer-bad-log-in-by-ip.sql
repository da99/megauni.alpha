

CREATE TABLE customer_bad_log_in_by_ip (
  ip                   inet         NOT NULL primary key ,
  log_in_at            date         NOT NULL DEFAULT current_date,
  bad_log_in_count     smallint     NOT NULL DEFAULT 0
);


-- DOWN

DROP TABLE IF EXISTS customer_bad_log_in_by_ip;


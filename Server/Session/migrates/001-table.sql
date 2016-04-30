


CREATE TABLE session (
    id TEXT NOT NULL PRIMARY KEY,
    expiry timestamp,
    session JSON
) engine=TokuDB;


-- DOWN

DROP TABLE IF EXISTS session CASCADE;



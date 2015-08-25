


CREATE TABLE session (
    id TEXT NOT NULL PRIMARY KEY,
    expiry timestamp,
    session JSON
);


-- DOWN

DROP TABLE IF EXISTS session CASCADE;



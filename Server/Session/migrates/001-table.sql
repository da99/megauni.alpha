


CREATE TABLE session (
    id TEXT NOT NULL PRIMARY KEY,
    expiry timestamp NOT NULL,
    session JSON
);


-- DOWN

DROP TABLE IF EXISTS session CASCADE;



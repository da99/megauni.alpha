
INSERT INTO file_name (id, file_name) VALUES (1, 'customer');

INSERT INTO file_name (id, file_name) VALUES (2, 'screen_name');
INSERT INTO file_name (id, file_name) VALUES (3, 'main');
INSERT INTO file_name (id, file_name) VALUES (4, 'follow');
INSERT INTO file_name (id, file_name) VALUES (5, 'ban');
INSERT INTO file_name (id, file_name) VALUES (6, 'editor');
INSERT INTO file_name (id, file_name) VALUES (7, 'friend');
INSERT INTO file_name (id, file_name) VALUES (8, 'semi-friend');
INSERT INTO file_name (id, file_name) VALUES (9, 'friend-enemy');

INSERT INTO file_name (id, file_name) VALUES (1000, 'blank'); -- Placeholder/marker.
-- DOWN

DELETE FROM file_name WHERE id <= 1000;



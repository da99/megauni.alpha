
INSERT INTO file_name (file_name) VALUES ('customer');

INSERT INTO file_name (file_name) VALUES ('screen_name');
INSERT INTO file_name (file_name) VALUES ('main');
INSERT INTO file_name (file_name) VALUES ('follow');
INSERT INTO file_name (file_name) VALUES ('ban');
INSERT INTO file_name (file_name) VALUES ('editor');
INSERT INTO file_name (file_name) VALUES ('friend');
INSERT INTO file_name (file_name) VALUES ('semi-friend');
INSERT INTO file_name (file_name) VALUES ('friend-enemy');

INSERT INTO file_name (id, file_name) VALUES (1000, 'blank');
-- DOWN

DELETE FROM file_name WHERE id <= 1000;



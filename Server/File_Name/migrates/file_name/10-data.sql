
-- DOWN
DELETE FROM file_name WHERE id <= 1000;

-- UP
INSERT IGNORE INTO file_name (id, file_name) VALUES
(1, 'customer'),
(2, 'screen_name'),
(3, 'main'),
(4, 'follow'),
(5, 'ban'),
(6, 'editor'),
(7, 'friend'),
(8, 'semi-friend'),
(9, 'friend-enemy'),
(1000, 'blank') -- Placeholder/marker.
;



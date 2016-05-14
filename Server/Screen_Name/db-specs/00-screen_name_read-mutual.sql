
-- Screen_Names set to WORLD READABLE can be viewed by
-- anyone.



INSERT INTO user (id, pswd_hash)
VALUES           (1,  'nothing');

INSERT INTO user (id, pswd_hash)
VALUES           (2,  'nothing');

INSERT INTO screen_name
       (id, owner_id, privacy, screen_name)
VALUES (1,  1, name_to_type_id('WORLD READABLE'), "sn_1");

INSERT INTO screen_name
       (id, owner_id, privacy, screen_name)
VALUES (2, 2, name_to_type_id('WORLD READABLE'), "sn_2");

SELECT audience_id, screen_name
FROM screen_name_read
WHERE audience_id = 1;

-- EXPECT
-- 1 sn_1
-- 1 sn_2



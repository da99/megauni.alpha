Table	Create Table
label	CREATE TABLE `label` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) NOT NULL,
  `label` varchar(30) NOT NULL,
  `body` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `label_unique_idx` (`owner_id`,`label`)
) ENGINE=TokuDB DEFAULT CHARSET=utf8

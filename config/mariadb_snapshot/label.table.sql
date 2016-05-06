Table	Create Table
label	CREATE TABLE `label` (\n  `id` int(11) NOT NULL AUTO_INCREMENT,\n  `owner_id` int(11) NOT NULL,\n  `label` varchar(30) NOT NULL,\n  `body` text,\n  PRIMARY KEY (`id`),\n  UNIQUE KEY `label_unique_idx` (`owner_id`,`label`)\n) ENGINE=TokuDB DEFAULT CHARSET=utf8

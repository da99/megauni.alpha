Table	Create Table
_versions	CREATE TABLE `_versions` (\n  `id` smallint(6) NOT NULL AUTO_INCREMENT,\n  `name` varchar(255) NOT NULL,\n  `file_name` varchar(255) NOT NULL,\n  PRIMARY KEY (`id`),\n  UNIQUE KEY `name_to_file_name_unique_idx` (`name`,`file_name`)\n) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8

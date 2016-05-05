Table	Create Table
file_name	CREATE TABLE `file_name` (\n  `id` smallint(6) NOT NULL AUTO_INCREMENT,\n  `file_name` varchar(30) NOT NULL,\n  PRIMARY KEY (`id`),\n  UNIQUE KEY `file_name_unique_idx` (`file_name`)\n) ENGINE=TokuDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8

Table	Create Table
file_name	CREATE TABLE `file_name` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `file_name` varchar(30) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `file_name_unique_idx` (`file_name`)
) ENGINE=TokuDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8

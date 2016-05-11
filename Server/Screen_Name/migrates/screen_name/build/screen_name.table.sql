Table	Create Table
screen_name	CREATE TABLE `screen_name` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) NOT NULL,
  `privacy` smallint(6) NOT NULL,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `screen_name` varchar(30) NOT NULL,
  `nick_name` varchar(30) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `trashed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `screen_name_unique_idx` (`parent_id`,`screen_name`)
) ENGINE=TokuDB DEFAULT CHARSET=utf8

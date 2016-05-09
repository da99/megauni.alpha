Table	Create Table
link	CREATE TABLE `link` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type_id` smallint(6) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `owner_type_id` smallint(6) NOT NULL,
  `a_id` int(11) NOT NULL,
  `a_type_id` smallint(6) NOT NULL,
  `b_id` int(11) NOT NULL,
  `b_type_id` smallint(6) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `link_unique_idx` (`type_id`,`owner_id`,`owner_type_id`,`a_id`,`a_type_id`,`b_id`,`b_type_id`)
) ENGINE=TokuDB DEFAULT CHARSET=utf8

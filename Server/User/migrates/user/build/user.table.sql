Table	Create Table
user	CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pswd_hash` binary(60) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `trashed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=TokuDB DEFAULT CHARSET=utf8

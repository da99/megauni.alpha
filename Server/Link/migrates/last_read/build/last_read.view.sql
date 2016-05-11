View	Create View	character_set_client	collation_connection
last_read	CREATE ALGORITHM=UNDEFINED DEFINER=`megauni`@`localhost` SQL SECURITY DEFINER VIEW `last_read` AS select `link`.`b_id` AS `publication_id`,`link`.`created_at` AS `at` from `link` where ((`link`.`type_id` = `name_to_type_id`('LAST READ AT')) and (`link`.`a_id` = `link`.`owner_id`))	utf8	utf8_general_ci

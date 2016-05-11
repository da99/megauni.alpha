View	Create View	character_set_client	collation_connection
follow	CREATE ALGORITHM=UNDEFINED DEFINER=`megauni`@`localhost` SQL SECURITY DEFINER VIEW `follow` AS select `link`.`a_id` AS `mask_id`,`link`.`b_id` AS `publication_id`,`link`.`created_at` AS `created_at` from `link` where ((`link`.`type_id` = `name_to_type_id`('FOLLOW')) and (`link`.`owner_id` = `link`.`a_id`))	utf8	utf8_general_ci

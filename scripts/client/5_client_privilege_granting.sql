
--##############################
-- Otis Database Privilege Granting
--##############################



-- admin
	Grant All Privileges 
		On All Tables In Schema main_schema 
		To admin_role
		;
-- --eol-- --
	Grant All Privileges 
		On All Functions In Schema main_schema 
		To admin_role
		;
-- --eol-- --
	Grant All Privileges 
		On All Tables In Schema notification_schema 
		To admin_role
		;
-- --eol-- --
	Grant All Privileges 
		On All Functions In Schema notification_schema 
		To admin_role 
		;
-- --eol-- --
-- general_user
	Grant All Privileges 
		On All Tables In Schema main_schema 
		To general_user
		;
-- --eol-- --
	Grant All Privileges 
		On All Functions In Schema main_schema 
		To general_user
		;
-- --eol-- --
	Grant All Privileges 
		On All Tables In Schema notification_schema 
		To general_user
		;
-- --eol-- --
	Grant All Privileges 
		On All Functions In Schema notification_schema 
		To general_user 
		;
-- --eol-- --
-- backup_role
	Grant All Privileges 
		On All Tables In Schema main_schema 
		To backup_role
		;
-- --eol-- --
	Grant All Privileges 
		On All Functions In Schema main_schema 
		To backup_role
		;
-- --eol-- --
	Grant All Privileges 
		On All Tables In Schema notification_schema 
		To backup_role
		;
-- --eol-- --
	Grant All Privileges 
		On All Functions In Schema notification_schema 
		To backup_role 
		;
-- --eol-- --
-- backup_role
	Grant All Privileges On Schema main_schema to backup_role;
-- --eol-- --
	Grant Select On All Sequences In Schema main_schema To backup_role;
	-- --eol-- --
	Grant Select On All Tables In Schema main_schema To backup_role;
	-- --eol-- --
	Grant All Privileges On Schema notification_schema to backup_role;
	-- --eol-- --
	Grant Select On All	Sequences In Schema notification_schema to backup_role;
	-- --eol-- --
	Grant Select On All Tables In Schema notification_schema to backup_role;
	-- --eol-- --
	Grant All Privileges On Schema info_schema to backup_role;
	-- --eol-- --
	Grant Select On All	Sequences In Schema info_schema to backup_role;
	-- --eol-- --
	Grant Select On All Tables In Schema info_schema to backup_role;
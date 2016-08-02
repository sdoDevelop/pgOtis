
--##############################
-- Otis Database Privilege Granting
--##############################



-- admin
	Grant All Privileges 
		On All Tables In Schema main_schema 
		To admin_role
		;

	Grant All Privileges 
		On All Functions In Schema main_schema 
		To admin_role
		;

	Grant All Privileges 
		On All Tables In Schema notification_schema 
		To admin_role
		;

	Grant All Privileges 
		On All Functions In Schema notification_schema 
		To admin_role 
		;

-- general_user
	Grant All Privileges 
		On All Tables In Schema main_schema 
		To general_user
		;

	Grant All Privileges 
		On All Functions In Schema main_schema 
		To general_user
		;

	Grant All Privileges 
		On All Tables In Schema notification_schema 
		To general_user
		;

	Grant All Privileges 
		On All Functions In Schema notification_schema 
		To general_user 
		;

-- backup_role
	Grant All Privileges 
		On All Tables In Schema main_schema 
		To backup_role
		;

	Grant All Privileges 
		On All Functions In Schema main_schema 
		To backup_role
		;

	Grant All Privileges 
		On All Tables In Schema notification_schema 
		To backup_role
		;

	Grant All Privileges 
		On All Functions In Schema notification_schema 
		To backup_role 
		;

-- backup_role
	Grant All Privileges On Schema main_schema to backup_role;
	Grant Select On All Sequences In Schema main_schema To backup_role;
	Grant Select On All Tables In Schema main_schema To backup_role;
	Grant All Privileges On Schema notification_schema to backup_role;
	Grant Select On All	Sequences In Schema notification_schema to backup_role;
	Grant Select On All Tables In Schema notification_schema to backup_role;

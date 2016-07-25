
--##############################
-- Otis Database Privilege Granting
--##############################



-- admin
	Grant All Privileges 
		On All Tables In Schema Public 
		To admin_role
		;

	Grant All Privileges 
		On All Functions In Schema Public 
		To admin_role
		;

	Grant All Privileges 
		On All Tables In Schema notification 
		To admin_role
		;

	Grant All Privileges 
		On All Functions In Schema notification 
		To admin_role 
		;

-- general_user
	Grant All Privileges 
		On All Tables In Schema Public 
		To general_user
		;

	Grant All Privileges 
		On All Functions In Schema Public 
		To general_user
		;

	Grant All Privileges 
		On All Tables In Schema notification 
		To general_user
		;

	Grant All Privileges 
		On All Functions In Schema notification 
		To general_user 
		;

-- backup_role
	Grant All Privileges 
		On All Tables In Schema Public 
		To backup_role
		;

	Grant All Privileges 
		On All Functions In Schema Public 
		To backup_role
		;

	Grant All Privileges 
		On All Tables In Schema notification 
		To backup_role
		;

	Grant All Privileges 
		On All Functions In Schema notification 
		To backup_role 
		;

-- backup_role
	Grant All Privileges On Schema public to backup_role;
	Grant Select On All Sequences In Schema public To backup_role;
	Grant Select On All Tables In Schema public To backup_role;
	Grant All Privileges On Schema notification to backup_role;
	Grant Select On All	Sequences In Schema notification to backup_role;
	Grant Select On All Tables In Schema notification to backup_role;



--##############################
-- Otis Database User Creation
--##############################


-- Drop all of the users we want to create 
	Drop Role If Exists 
		serveradmin
		;

	Drop Role If Exists 
		transfer_monkey
		;

	Drop Role If Exists 
		sean
		;

	Drop Role If Exists 
		benassef
		;

-- Drop all of the roles we want to create
	Drop Role If Exists 
		god_mode
		;

Drop Role If Exists 
		admin_role
		;

Drop Role If Exists 
		general_user
		;

Drop Role If Exists 
		backup_role
		;

-- Create our group roles
	Create Role
		god_mode 
		SUPERUSER
		;

	Create Role
		admin_role 
		CreateDB 
		CreateRole 
		CreateUser 
		;

	Create Role
		general_user 
		CreateDB 
		CreateRole 
		;

	Create Role
		backup_role 
		SUPERUSER
		;


-- Create our Users
	Create User
		serveradmin 
		;
	Grant god_mode To serveradmin;

	Create User
		transfer_monkey
		With Encrypted Password 'this monkey transfers data'
		;
	Grant backup_role To transfer_monkey;

	Create User
		sean
		;
	Grant general_user To sean;

	Create User
		benassef
		;
	Grant general_user To benassef;

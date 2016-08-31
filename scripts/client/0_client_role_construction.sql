

--##############################
-- Otis Database User Creation
--##############################

	Drop Database If Exists 
		otis_main
		;
-- --eol-- --

-- Drop all of the users we want to create 
	Drop Role If Exists 
		serveradmin
		;
-- --eol-- --
	Drop Role If Exists 
		transfer_monkey
		;
-- --eol-- --
	Drop Role If Exists 
		sean
		;
-- --eol-- --
	Drop Role If Exists 
		benassef
		;
-- --eol-- --
-- Drop all of the roles we want to create
	Drop Role If Exists 
		god_mode
		;
-- --eol-- --
Drop Role If Exists 
		admin_role
		;
-- --eol-- --
Drop Role If Exists 
		general_user
		;
-- --eol-- --
Drop Role If Exists 
		backup_role
		;
-- --eol-- --
-- Create our group roles
	Create Role
		god_mode 
		SUPERUSER
		;
-- --eol-- --
	Create Role
		admin_role 
		CreateDB 
		CreateRole 
		CreateUser 
		;
-- --eol-- --
	Create Role
		general_user 
		CreateDB 
		CreateRole 
		;
-- --eol-- --
	Create Role
		backup_role 
		SUPERUSER
		;
-- --eol-- --

-- Create our Users
	Create User
		serveradmin 
		SUPERUSER
		;
-- --eol-- --
	Grant god_mode To serveradmin;
-- --eol-- --
	Create User
		transfer_monkey
		With Encrypted Password 'this monkey transfers data'
		SUPERUSER
		;
-- --eol-- --
	Grant backup_role To transfer_monkey;
-- --eol-- --
	Create User
		sean
		;
-- --eol-- --
	Grant general_user To sean;
-- --eol-- --
	Create User
		benassef
		;
-- --eol-- --
	Grant general_user To benassef;
-- --eol-- --

-- Now we need to create it again
	Create Database otis_main 
		With Owner = serveradmin
		;

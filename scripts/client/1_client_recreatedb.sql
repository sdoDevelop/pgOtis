
-- ##################################
-- ###### Create Otis Database ######
-- ##################################


-- Delete the database if it exists
	Drop Database If Exists otis_main;
-- --eol-- --
-- Now we need to create it again
	Create Database otis_main 
		With Owner = serveradmin
		;
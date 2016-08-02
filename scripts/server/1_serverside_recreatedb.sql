-- ##################################
-- ###### Create Otis Database ######
-- ##################################


-- Delete the database if it exists
	Drop Database If Exists otis_data;

-- Now we need to create it again
	Create Database otis_data 
		With Owner = serveradmin
		;
/*
========================================================================
Create Database and Schemas 
========================================================================
Script purpose:
  This scripts creates a new database named 'datawarehouse' after checking if they already exists.  named bronze, silver and gold.
  If the database already exists, it is dropped and recreated. After that, the script sets up 3 new schemas within the new database
  named: 'bronze', 'silver' and 'gold'.
Warning:
  Running this script will drop the database named datawarehouse if they exist.
  All data in the database will be permanently deleted. Proceed with caution and create proper backups before running the script.
  The script is made for PosgreSQL and run in a terminal.
*/

-- Drop and recreate the 'Datawarehouse' database using psql
DROP DATABASE IF EXISTS datawarehouse WITH(FORCE);
CREATE DATABASE datawarehouse;

-- Create schemas
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;




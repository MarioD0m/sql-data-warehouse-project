/*

========================================================================
Create Schemas 
========================================================================
Script purpose:
  This scripts creates 3 new databases (schemas) after checking if they already exists in MySQL named bronze, silver and gold.
  If the schema exists, it is dropped and recreated.
Warning:
  Running this script will drop the databases named bronze, silver and gold if they exist.
  All data in those schemas will be permanently deleted. Proceed with caution and create
  proper backups before running the script.
*/

use sys;

/* Drop the database bronze if it exists, and then recreate it */
DROP DATABASE IF EXISTS bronze;
CREATE DATABASE bronze;
/* Drop the database silver if it exists, and then recreate it */
DROP DATABASE IF EXISTS silver;
CREATE DATABASE silver;
/* Drop the database gold if it exists, and then recreate it */
DROP DATABASE IF EXISTS gold;
CREATE DATABASE gold;

show databases;

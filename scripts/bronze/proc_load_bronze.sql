/*
========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
========================================================================
Script purpose:
  This stored procedure loads data into the Bronze schema from external
  CSV files one table at a time. This script was made for PostgreSQL.
  It performs the following actions:
  - Truncates the bronze tables before loading the data.
  - Uses the 'COPY' command to load data from csv files to bronze tables.
Warnings:
  Change the base directory to your actual file path. 
  Example: 'C:/dwh/datasets/source_crm/cust_info.csv'
  
Parameters:
  None.
Using example:
  CALL bronze.load_bronze();
========================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    err_message TEXT;
    err_detail  TEXT;
    err_hint    TEXT;
    err_code    TEXT;
    start_time  TIMESTAMP;
    end_time  TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;

BEGIN

    RAISE NOTICE '======================================================================';
    RAISE NOTICE '                       LOADING BRONZE LAYER                           ';
    RAISE NOTICE '======================================================================';
    
    -- Sets the start time of the batch loading
    batch_start_time := clock_timestamp();
    
    RAISE NOTICE '-------------------------------------';
    RAISE NOTICE 'Loading CRM tables';
    RAISE NOTICE '-------------------------------------';

    -- Truncate and bulk insert data from the CRM source to the designated tables
    -- Sets the start and end time to calculate the loading time of each table
    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.crm_cust_info;
    RAISE NOTICE '--> Truncating table:[bronze.crm_cust_info]';
    COPY bronze.crm_cust_info
    FROM '/.../datasets/source_crm/cust_info.csv'
    WITH (FORMAT csv, HEADER true);
    RAISE NOTICE '--> Inserting data into table:[bronze.crm_cust_info]';
    end_time := clock_timestamp();
    RAISE NOTICE '>>>> Load duration: % s', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);

    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.crm_prd_info;
    RAISE NOTICE '--> Truncating table:[bronze.crm_cust_info]';
    COPY bronze.crm_prd_info
    FROM '/.../datasets/source_crm/prd_info.csv'
    WITH (FORMAT csv, HEADER true);
    RAISE NOTICE '--> Inserting data into table:[bronze.crm_cust_info]';
    end_time := clock_timestamp();
    RAISE NOTICE '>>>> Load duration: % s', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);

    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.crm_sales_details;
    RAISE NOTICE '--> Truncating table:[bronze.crm_cust_info]';
    COPY bronze.crm_sales_details
    FROM '/.../datasets/source_crm/sales_details.csv'
    WITH (FORMAT csv, HEADER true);
    RAISE NOTICE '--> Inserting data into table:[bronze.crm_cust_info]';
    end_time := clock_timestamp();
    RAISE NOTICE '>>>> Load duration: % s', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);

    RAISE NOTICE '-------------------------------------';
    RAISE NOTICE 'Loading ERP tables';
    RAISE NOTICE '-------------------------------------';

    -- Truncate and bulk insert data from the ERP source to the designated tables
    -- Sets the start and end time to calculate the loading time of each table
    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.erp_cust_az12;
    RAISE NOTICE '--> Truncating table:[bronze.crm_cust_info]';
    COPY bronze.erp_cust_az12
    FROM '/.../datasets/source_erp/CUST_AZ12.csv'
    WITH (FORMAT csv, HEADER true);
    RAISE NOTICE '--> Inserting data into table:[bronze.crm_cust_info]';
    end_time := clock_timestamp();
    RAISE NOTICE '>>>> Load duration: % s', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);

    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.erp_loc_a101;
    RAISE NOTICE '--> Truncating table:[bronze.crm_cust_info]';
    COPY bronze.erp_loc_a101
    FROM '/.../datasets/source_erp/LOC_A101.csv'
    WITH (FORMAT csv, HEADER true);
    RAISE NOTICE '--> Inserting data into table:[bronze.crm_cust_info]';
    end_time := clock_timestamp();
    RAISE NOTICE '>>>> Load duration: % s', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);

    start_time := clock_timestamp();
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    RAISE NOTICE '--> Truncating table:[bronze.crm_cust_info]';
    COPY bronze.erp_px_cat_g1v2
    FROM '/.../datasets/source_erp/PX_CAT_G1V2.csv'
    WITH (FORMAT csv, HEADER true);
    RAISE NOTICE '--> Inserting data into table:[bronze.crm_cust_info]';
    end_time := clock_timestamp();
    RAISE NOTICE '>>>> Load duration: % s', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);

    -- Sets the start time of the batch loading and calculate the total batch time
    batch_end_time := clock_timestamp();
    RAISE NOTICE '======================================================================';
    RAISE NOTICE 'LOADING COMPLETE: % s', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
    RAISE NOTICE '======================================================================';

    -- If a loading error occurs, the exception stops the process and send a message with the details of
    -- the error.
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS 
            err_code    = RETURNED_SQLSTATE,
            err_message = MESSAGE_TEXT,
            err_detail  = PG_EXCEPTION_DETAIL,
            err_hint    = PG_EXCEPTION_HINT;

        RAISE NOTICE '======================================================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING OF THE BRONZE LAYER            ';
        RAISE NOTICE 'ERROR CODE: %', err_code;
        RAISE NOTICE 'ERROR MESSAGE: %', err_message;
        RAISE NOTICE 'ERROR DETAIL: %', err_detail;
        RAISE NOTICE '======================================================================';
END;
$$;

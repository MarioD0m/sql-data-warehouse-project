/*
========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
========================================================================
Script purpose:
  This stored procedure loads data into the Bronze schema from external
  CSV files using a Loop. This script was made for PostgreSQL.
  It performs the following actions:
  - Truncates the bronze tables before loading the data.
  - Uses the 'COPY' command to load data from csv files to bronze tables.
Warnings:
  Change the base directory to your actual file path. 
  Example: 'C:/dwh/datasets/source_crm/cust_info.csv'
  
Parameters:
  - p_base_dir: file path to the root directory that contains the folders for 
    CRM (../datasets/source_crm/) and ERP (../datasets/source_erp/) files with
    the CSV files inside them.
  - p_table_names: the striped name of the CSV files inside the folders which 
    will be inserted into bronze tables.
Using example:
  CALL bronze.bulk_load_bronze(
    p_base_dir    => '/.../datasets',
    p_table_names => ARRAY['cust_info', 'prd_info', 'sales_details','CUST_AZ12', 'LOC_A101', 'PX_CAT_G1V2'] );
========================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.bulk_load_bronze (
    p_base_dir    TEXT,                     
    p_table_names TEXT[],
    p_has_header  TEXT DEFAULT 'TRUE'
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Table and prefix variables
    v_table     TEXT;
    v_file_path TEXT;
    v_full_table     TEXT;
    v_sql       TEXT;
    v_prefix     TEXT;
    v_counter    INT := 0;
    -- Error handling varibles
    err_message TEXT;
    err_detail  TEXT;
    err_hint    TEXT;
    err_code    TEXT;
    -- Time variables
    start_time  TIMESTAMP;
    end_time  TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    RAISE NOTICE '======================================================================';
    RAISE NOTICE '                      LOADING BRONZE LAYER                            ';
    RAISE NOTICE '======================================================================';

    -- Start the timer to check the batch elapsed time
    batch_start_time := clock_timestamp();

    -- For loop to iterate each name file in the parameter list
    FOREACH v_table IN ARRAY p_table_names
    LOOP
        -- Begin for the EXCEPT clause
        BEGIN

            -- Start the timer to check the time to insert the data into de table
            start_time := clock_timestamp();
           
            -- Counter to seggregate CRM and ERP sources depending on the file index
            v_counter := v_counter + 1;
            IF v_counter <= 3 THEN
                v_prefix := 'crm';
            ELSE
                v_prefix := 'erp';
            END IF;

            IF v_counter = 1 THEN
                RAISE NOTICE '-------------------------------------';
                RAISE NOTICE '         Loading CRM tables';
                RAISE NOTICE '-------------------------------------';
            ELSIF v_counter = 4 THEN
                RAISE NOTICE '-------------------------------------';
                RAISE NOTICE '         Loading ERP tables'; 
                RAISE NOTICE '-------------------------------------';
            END IF;

            -- Add the prefix for the table name and also completes the file path considering the 
            -- prefix for the source of the files (CRM and ERP sources)
            v_full_table := v_prefix || '_' || lower(v_table);
            v_file_path  := rtrim(p_base_dir,'/') || '/source_' || v_prefix || '/' || v_table || '.csv';

            -- Trucate the table
            RAISE NOTICE '--> Truncating table: [bronze.%]', v_full_table;
            EXECUTE format('TRUNCATE TABLE bronze.%I', v_full_table);

            -- Copy the data from the file into the table 
            RAISE NOTICE '--> Inserting data into table: [bronze.%]', v_full_table;
            v_sql := format(
                'COPY bronze.%I FROM %L WITH (FORMAT csv, HEADER %s)',
                v_full_table,
                v_file_path,
                p_has_header
            );
            EXECUTE v_sql;

            -- Stops the timer to check the time to insert the data into de table and print
            -- the elapsed time
            end_time := clock_timestamp();
            RAISE NOTICE '>>>> Load duration: % s', ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);

        -- Exceptions handling 
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS 
                err_code    = RETURNED_SQLSTATE,
                err_message = MESSAGE_TEXT,
                err_detail  = PG_EXCEPTION_DETAIL,
                err_hint    = PG_EXCEPTION_HINT;

            RAISE NOTICE '======================================================================';
            RAISE NOTICE '         ERROR OCCURRED DURING LOADING OF THE BRONZE LAYER            ';
            RAISE NOTICE '         ERROR CODE: %', err_code;
            RAISE NOTICE '         ERROR MESSAGE: %', err_message;
            RAISE NOTICE '         ERROR DETAIL: %', err_detail;
            RAISE NOTICE '======================================================================';
        
        END;
    END LOOP;

    -- Stops the timer to check the batch elapsed time
    batch_end_time := clock_timestamp();

    RAISE NOTICE '======================================================================';
    RAISE NOTICE '                  LOADING COMPLETE: % s', ROUND(EXTRACT(EPOCH FROM (batch_end_time - batch_start_time))::numeric, 3);
    RAISE NOTICE '======================================================================';

END;
$$;


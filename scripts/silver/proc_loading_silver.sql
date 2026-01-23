/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    call silver.load_silver();
===============================================================================
*/
CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE batch_start_time TIMESTAMPTZ; batch_end_time TIMESTAMPTZ; start_time TIMESTAMPTZ; end_time TIMESTAMPTZ;
BEGIN
	batch_start_time:=clock_timestamp();
	start_time:=clock_timestamp();
    RAISE NOTICE 'truncating table silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;

    RAISE NOTICE 'Loading table silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info (
        cst_id, cst_key, cst_firstname, cst_lastname,
        cst_marital_status, cst_gndr, cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC
               ) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;
	end_time:=clock_timestamp();
	RAISE NOTICE 'Load Duration: % Seconds', extract(epoch from (end_time-start_time));

	start_time:=clock_timestamp();
    RAISE NOTICE 'truncating table silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;

    RAISE NOTICE 'Loading table silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info (
        prd_id, cat_id, prd_key, prd_nm,
        prd_cost, prd_line, prd_start_dt, prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
        SUBSTRING(prd_key, 7),
        prd_nm,
        COALESCE(prd_cost, 0),
        CASE
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END,
        prd_start_dt,
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ) - 1 AS prd_end_dt
    FROM bronze.crm_prd_info;
	end_time:=clock_timestamp();
	RAISE NOTICE 'Loading time: % seconds', extract(epoch from (end_time-start_time));

	start_time:=clock_timestamp();
	RAISE NOTICE 'Start time: % Seconds', start_time;
    RAISE NOTICE 'truncating table silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;

    RAISE NOTICE 'Loading table silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id,
        sls_order_dt, sls_ship_dt, sls_due_dt,
        sls_sales, sls_quantity, sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE
            WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::varchar) <> 8 THEN NULL
            ELSE CAST(sls_order_dt::varchar AS date)
        END,
        CASE
            WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::varchar) <> 8 THEN NULL
            ELSE CAST(sls_ship_dt::varchar AS date)
        END,
        CASE
            WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::varchar) <> 8 THEN NULL
            ELSE CAST(sls_due_dt::varchar AS date)
        END,
        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,
        sls_quantity,
        CASE
            WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END
    FROM bronze.crm_sales_details;
	end_time:=clock_timestamp();
	RAISE NOTICE 'Loading time: % Seconds', extract(epoch from (end_time-start_time));

	start_time:=clock_timestamp();
    RAISE NOTICE 'truncating table silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;

    RAISE NOTICE 'Loading table silver.erp_cust_az12';
    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
            ELSE cid
        END,
        CASE
            WHEN bdate > NOW() THEN NULL
            ELSE bdate
        END,
        CASE
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            ELSE 'n/a'
        END
    FROM bronze.erp_cust_az12;
	end_time:=clock_timestamp();
	RAISE NOTICE 'Loading time: % Seconds', extract(epoch from (end_time-start_time));
	
	start_time:=clock_timestamp();
	RAISE NOTICE 'Start time: % Seconds', start_time;
    RAISE NOTICE 'truncating table silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;

    RAISE NOTICE 'Loading table silver.erp_loc_a101';
    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', ''),
        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
            WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'n/a'
            ELSE TRIM(cntry)
        END
    FROM bronze.erp_loc_a101;
	end_time:=clock_timestamp();
	RAISE NOTICE 'Loading time: % Seconds', extract(epoch from (end_time-start_time));

	start_time:=clock_timestamp();
    RAISE NOTICE 'truncating table silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    RAISE NOTICE 'Loading table silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2
    SELECT * FROM bronze.erp_px_cat_g1v2;
	end_time:=clock_timestamp();
	RAISE NOTICE 'Loading time: % Seconds', extract(epoch from (end_time-start_time));
	
	batch_end_time:=clock_timestamp();
	RAISE NOTICE 'Batch time stamp: % Seconds', extract(epoch from (batch_end_time-batch_start_time));
EXCEPTION
	WHEN OTHERS THEN 
	RAISE NOTICE 'Error occured while loading Silver layer';
	RAISE NOTICE 'Error Message:%', sqlerrm;
	RAISE NOTICE 'Error state:%', sqlstate;
END;
$$;

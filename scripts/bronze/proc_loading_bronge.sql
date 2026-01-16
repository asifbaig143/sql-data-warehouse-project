/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `COPY` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL bronze.load_bronze;
===============================================================================
*/


create or replace procedure bronze.loading_bronze() 
language plpgsql
as $$
declare batch_start_time timestamptz; batch_end_time timestamptz; start_time timestamptz; end_time timestamptz;
begin
  batch_start_time:=clock_timestamp();
	raise notice '---------------------';
	raise notice 'loading bronze layer';
	raise notice '---------------------';
	
	start_time:=clock_timestamp();
	raise notice ' truncating crm_cust_info';
	truncate table bronze.crm_cust_info;
	raise notice '---------------------';
	raise notice 'loading crm_cust_info';
	copy bronze.crm_cust_info from 'E:\cust_info.csv' with ( format csv, header true, delimiter ',');
	end_time:=clock_timestamp();
	raise notice 'load Duration: % seconds', extract(epoch from (end_time-start_time));

	start_time:=clock_timestamp();
	raise notice '---------------------';
	raise notice ' truncating crm_sales_details';
	truncate table bronze.crm_sales_details;
	raise notice '---------------------';
	raise notice 'loading crm_sales_details';
	copy bronze.crm_sales_details from 'E:\sales_details.csv' with ( format csv, header true, delimiter ',');
	end_time:=clock_timestamp();
	raise notice 'load Duration: % seconds', extract(epoch from (end_time-start_time));
	
	start_time:=clock_timestamp();
	raise notice '---------------------';
	raise notice ' truncating crm_prd_info';
	truncate table bronze.crm_prd_info;
	raise notice '---------------------';
	raise notice 'loading crm_prd_info';
	copy bronze.crm_prd_info from 'E:\prd_info.csv' with ( format csv, header true, delimiter ',');
	end_time:=clock_timestamp();
	raise notice 'load Duration: % seconds', extract(epoch from (end_time-start_time));
	
	start_time:=clock_timestamp();
	raise notice '---------------------';
	raise notice ' truncating erp_cust_az12';
	truncate table bronze.erp_cust_az12;
	raise notice '---------------------';
	raise notice 'loading erp_cust_az12';
	copy bronze.erp_cust_az12 from 'E:\CUST_AZ12.csv' with ( format csv, header true, delimiter ',');
	end_time:=clock_timestamp();
	raise notice 'load Duration: % seconds', extract(epoch from (end_time-start_time));
	
	start_time:=clock_timestamp();
	raise notice '---------------------';
	raise notice ' truncating erp_loc_a101';
	truncate table bronze.erp_loc_a101;
	raise notice '---------------------';
	raise notice 'loading erp_loc_a101';
	copy bronze.erp_loc_a101 from 'E:\LOC_A101.csv' with ( format csv, header true, delimiter ',');
	end_time:=clock_timestamp();
	raise notice 'load Duration: % seconds', extract(epoch from (end_time-start_time));
	
	start_time:=clock_timestamp();
	raise notice '---------------------';
	raise notice ' truncating erp_cat_g1v2';
	truncate table bronze.erp_px_cat_g1v2;
	raise notice '---------------------';
	raise notice 'loading erp_px_cat_g1v2';
	copy bronze.erp_px_cat_g1v2 from 'E:\PX_CAT_G1V2.csv' with ( format csv, header true, delimiter ',');
	end_time:=clock_timestamp();
	raise notice 'load Duration: % seconds', extract(epoch from (end_time-start_time));
	raise notice '---------------------';
	batch_end_time:=clock_timestamp();
	raise notice 'Total bronze layer load Duration: % seconds', extract(epoch from (batch_end_time-batch_start_time));
exception 
  when others then
	raise notice 'Error occured during loading bronze layer';
	raise notice 'Error Message: %', sqlerrm;
	raise notice 'Error code: %', sqlstate;
end;
$$;


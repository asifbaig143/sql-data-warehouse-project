/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/
/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

DROP TABLE IF EXISTS silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info (
    cst_id              INTEGER,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE,
	dwh_create_date TIMESTAMPTZ  DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id       INTEGER,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INTEGER,
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE,
	dwh_create_date TIMESTAMPTZ DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INTEGER,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    INTEGER,
    sls_quantity INTEGER,
    sls_price    INTEGER,
	dwh_create_date TIMESTAMPTZ DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
    cid    VARCHAR(40),
    cntry  VARCHAR(40),
	dwh_create_date TIMESTAMPTZ DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
    cid    VARCHAR(40),
    bdate  DATE,
    gen    VARCHAR(20),
	dwh_create_date TIMESTAMPTZ DEFAULT NOW()
);

DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
    id           VARCHAR(40),
    cat          VARCHAR(40),
    subcat       VARCHAR(40),
    maintenance  VARCHAR(40),
	dwh_create_date TIMESTAMPTZ DEFAULT NOW()
);

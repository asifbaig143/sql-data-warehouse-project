/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

DROP TABLE IF EXISTS bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id              INTEGER,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
);

DROP TABLE IF EXISTS bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info (
    prd_id       INTEGER,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INTEGER,
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE
);

DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INTEGER,
    sls_order_dt INTEGER,
    sls_ship_dt  INTEGER,
    sls_due_dt   INTEGER,
    sls_sales    INTEGER,
    sls_quantity INTEGER,
    sls_price    INTEGER
);

DROP TABLE IF EXISTS bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    cid    VARCHAR(40),
    cntry  VARCHAR(40)
);

DROP TABLE IF EXISTS bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
    cid    VARCHAR(40),
    bdate  DATE,
    gen    VARCHAR(20)
);

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           VARCHAR(40),
    cat          VARCHAR(40),
    subcat       VARCHAR(40),
    maintenance  VARCHAR(40)
);

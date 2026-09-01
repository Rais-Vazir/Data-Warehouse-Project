--DDL Script:- This script Create 'Silver' Tables
--This Sripts Create Tables in 'Silver' schema

if OBJECT_ID('silver.crm_cust_info','u') is not null
   drop table silver.crm_cust_info; 
create table silver.crm_cust_info (
cst_id varchar(55),
cst_key varchar (100),
cst_firstname varchar (55),
cst_lastname varchar (55),
cst_martial_status varchar (10),
cst_gender varchar (10),
cst_create_date date,
dwh_create_date datetime2 default GETDATE()
);

if OBJECT_ID('silver.crm_prd_info','u') is not null
   drop table silver.crm_prd_info; 
create table silver.crm_prd_info (
prd_id          int,
cat_id          varchar(50),
prd_key         varchar(55),
prd_name        varchar(55),
prd_cost        int,
prd_line        varchar(50),
prd_start_dt    date,
prd_end_dt      date,
dwh_create_date datetime2 default GETDATE()
);


if OBJECT_ID('silver.crm_sales_details','u') is not null
   drop table silver.crm_sales_details; 
create table silver.crm_sales_details (
sls_ord_num   varchar(50),
sls_prd_key   varchar(50),
sls_cst_id    int,
sls_order_dt  date,
sls_ship_dt   date,
sls_due_dt    date,
sls_sales     int,
sls_quantity  int,
sls_price     int,
dwh_create_date datetime2 default GETDATE()
);


if OBJECT_ID('silver.erp_loc_a101','u') is not null
   drop table silver.erp_loc_a101; 
create table silver.erp_loc_a101 (
cid   varchar(50),
cntry varchar(50),
dwh_create_date datetime2 default GETDATE()
);


if OBJECT_ID('silver.erp_cust_az12','u') is not null
   drop table silver.erp_cust_az12; 
create table silver.erp_cust_az12 (
cid    varchar(50),
bdate  date,
gen    varchar(20),
dwh_create_date datetime2 default GETDATE()
);


if OBJECT_ID('silver.erp_px_cat_g1v2','u') is not null
   drop table silver.erp_px_cat_g1v2;
create table silver.erp_px_cat_g1v2 (
id          varchar(20),
cat         varchar(50),
subcat      varchar(50),
maintenance varchar(20),
dwh_create_date datetime2 default GETDATE()
);  

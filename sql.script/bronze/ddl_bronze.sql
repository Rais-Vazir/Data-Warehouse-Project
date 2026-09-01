
--DDL scripts:- Create Bronze Tables--
--This scripts create tables in bronze schema--  

create table bronze.crm_cust_info (
cst_id int,
cst_key varchar (100),
cst_firstname varchar (55),
cst_lastname varchar (55),
cst_martial_status varchar (10),
cst_gender varchar (10),
cst_create_date date
);

create table bronze.crm_prd_info (
prd_id          int,
prd_key         varchar(55),
prd_name        varchar(55),
prd_cost        int,
prd_line        varchar(50),
prd_start_dt    datetime,
prd_end_dt      datetime,
);

create table bronze.crm_sales_details (
sls_ord_num   varchar(50),
sls_prd_key   varchar(50),
sls_cst_id    int,
sls_order_dt  int,
sls_ship_dt   int,
sls_due_dt    int,
sls_sales     int,
sls_quantity  int,
sls_price     int
);


create table bronze.erp_loc_a101 (
cid   varchar(50),
cntry varchar(50)
);

create table bronze.erp_cust_az12 (
cid    varchar(50),
bdate  date,
gen    varchar(20)
);

create table bronze.erp_px_cat_g1v2 (
id          varchar(20),
cat         varchar(50),
subcat      varchar(50),
maintenance varchar(20)
);  

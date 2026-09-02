/*
  DDl Scripts:- Create Gold Views
  This script create view for gold layer in data warehouse
  Gold layer represent the final dimension and fact tables (Star Schema)*/

--============================================================
-- Create Dimension:- gold.dim_customers
--============================================================
create view gold.dim_customers as
select 
ROW_NUMBER () over(order by cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as customer_firstname,
ci.cst_lastname as customer_lastname,
la.cntry as country,
ci.cst_martial_status as martial_status,
ci.cst_gender as gender,
ci.cst_create_date as create_date,
ca.bdate birth_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key = la.cid
  
--============================================================
-- Create Dimension:- gold.dim_products
--============================================================
create view gold.dim_products as
select 
ROW_NUMBER () over(order by prd_start_dt) as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_name as product_name,
pn.cat_id as category_id,
ct.cat as category,
ct.subcat as subcategory,
ct.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 ct
on pn.cat_id = ct.id
where pn.prd_end_dt is null --remove duplicate/old product, filter out all historical data

--============================================================
-- Create Fact:- gold.fact_sales
--============================================================
create view gold.fact_sales as
select 
sd.sls_ord_num as order_number,
dp.product_key ,
dc.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as ship_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_products dp
on sd.sls_prd_key = dp.product_number
left join gold.dim_customers dc
on sd.sls_cst_id = dc.customer_id



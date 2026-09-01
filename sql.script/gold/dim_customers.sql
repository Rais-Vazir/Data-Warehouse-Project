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

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

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

/* This script perform quality check to validate the intigrity, consistency 
and accuracy of each table*/

--run this query before inserting data into silver layer 
--also run after loading into silver layer to check the quality
--==========================================================================
--Checking 'silver.crm_cust_info'
--==========================================================================
--CHECK FOR DUPLICATES AND NULLS IN PRIMARY KEY
select * from silver.crm_cust_info
where cst_id is null

select cst_id,
COUNT(*)
from silver.crm_cust_info
group by cst_id
having COUNT(*) > 1

--CHECK FOR UNWANTED SPACES IN STRINGS

select cst_firstname from silver.crm_cust_info
where cst_firstname != TRIM(cst_firstname)

select cst_lastname from silver.crm_cust_info
where cst_lastname != TRIM(cst_lastname)

--DATA NORMALIZATION OR STANDARDIZATION & CONSISTENCNY

select distinct cst_gender from silver.crm_cust_info

select distinct cst_martial_status from silver.crm_cust_info
  
--==========================================================================
--Checking 'silver.crm_prd_info'
--==========================================================================
--CHECK FOR DUPLICATES AND NULLS IN PRIMARY KEY
select * from bronze.crm_prd_info
select * from bronze.crm_sales_details
select * from bronze.erp_px_cat_g1v2

select
prd_id,
COUNT(*)
from silver.crm_prd_info
group by prd_id
having COUNT(*) >1 or prd_id is null

--CHECK FOR UNWANTED SPACES IN STRINGS
select prd_name from bronze.crm_prd_info
where prd_name != TRIM(prd_name) or prd_name is null

--CHECK FOR NULLS OR NEGATIVE NUMBERS
select prd_cost from silver.crm_prd_info
where prd_cost < 1 or prd_cost is null

--DATA NORMALIZATION OR STANDARDIZATION
select distinct prd_line from silver.crm_prd_info

--CHECK FOR INVALID DATE ORDER
select * from silver.crm_prd_info
where prd_start_dt > prd_end_dt

select 
prd_id,
prd_key,
prd_name,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as prd_end_dt_tst
from bronze.crm_prd_info
where prd_key in ('AC-HE-HL-U509-R','AC-HE-HL-U509')
  
--==========================================================================
--Checking 'bronze.crm_sales_details_info'
--==========================================================================
--CHECK FOR DUPLICATES AND NULLS IN PRIMARY KEY

select * from bronze.crm_sales_details

select sls_ord_num,
COUNT(*)
from silver.crm_sales_details
group by sls_ord_num
having COUNT(*) < 1 or sls_ord_num is null

select sls_prd_key 
from bronze.crm_sales_details
where sls_prd_key not in(select prd_key from silver.crm_prd_info)

select sls_cst_id
from bronze.crm_sales_details
where sls_cst_id not in(select cst_id from silver.crm_cust_info)

select NULLIF(sls_order_dt,0)
from silver.crm_sales_details
where sls_order_dt <= 0 or LEN(sls_order_dt) <>8 or
sls_order_dt > sls_ship_dt or
sls_order_dt > sls_due_dt


select sls_ship_dt
from bronze.crm_sales_details
where sls_ship_dt <= 0 or LEN(sls_ship_dt) !=8 or
sls_ship_dt < sls_order_dt or
sls_ship_dt > sls_due_dt

select sls_due_dt
from bronze.crm_sales_details
where sls_due_dt <= 0 or LEN(sls_due_dt) !=8 or
sls_due_dt < sls_order_dt or
sls_due_dt < sls_ship_dt

--CHECK FOR INVALID DATE OREDRS
select * from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

select * from silver.crm_sales_details
where sls_ship_dt < sls_order_dt or sls_ship_dt > sls_due_dt

select * from silver.crm_sales_details
where sls_due_dt < sls_order_dt or  sls_due_dt < sls_order_dt

--CHECK DATA CONSISTENCY BETWEEN SALES, QUANTITY AND PRICE 
--SALES = QUANTITY * PRICE
--VALUES MUST NOT BE NULL, ZERO, OR NEGATIVE
select distinct
sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price 
or sls_sales <= 0 or sls_sales is null  
or sls_quantity <= 0 or sls_quantity is null  
or sls_price <= 0 or sls_price is null
order by sls_sales, sls_quantity, sls_price;

select sls_sales, sls_quantity, sls_price,
case 
    when sls_sales != sls_quantity * ABS(sls_price) or sls_sales <= 0 or sls_sales is null
    then sls_quantity * ABS(sls_price)
    else sls_sales
end as sls_sales,
case 
     when sls_price <= 0 or sls_price is null
     then sls_sales / sls_quantity
     else sls_price
end as sls_price
from bronze.crm_sales_details
  
--==========================================================================
--Checking 'bronze.erp_cust_az12'
--==========================================================================
--CHECKING erp_cust_az12 TABLE'S CID
select
cid,
CASE
    WHEN cid like 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	ELSE cid
END AS cid,
bdate,
gen
from bronze.erp_cust_az12
where CASE
    WHEN cid like 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
	ELSE cid
END not in (select cst_key from silver.crm_cust_info)

--CHECKING erp_cust_az12 TABLE'S BDATE
select MIN(bdate) from bronze.erp_cust_az12;
select max(bdate) from bronze.erp_cust_az12;

select * from bronze.erp_cust_az12
where bdate < '1926-01-01' or bdate > GETDATE();

--DATA STANDARDIZATION AND CONSISTENCY
select distinct gen,
CASE
   WHEN UPPER(LTRIM(RTRIM(gen))) in ('F','FEMALE') then 'Female'
   when UPPER(LTRIM(RTRIM(gen))) in ('M','MALE') then 'Male'
   else 'n/a'
end as gen_new
from bronze.erp_cust_az12

select distinct gen,
UPPER(LTRIM(RTRIM(gen))) as cleaned_gen,
CASE
   WHEN UPPER(LTRIM(RTRIM(gen))) = 'F' then 'YES'
   WHEN UPPER(LTRIM(RTRIM(gen))) = 'M' then 'YES'
   WHEN UPPER(LTRIM(RTRIM(gen))) = 'FEMALE' then 'YES'
   WHEN UPPER(LTRIM(RTRIM(gen))) = 'MALE' then 'YES'
   else 'NO'
end as test
from bronze.erp_cust_az12

select 
gen,
case when gen is null or TRIM(gen) = '' then 'n/a'
else gen
end as gen2
from bronze.erp_cust_az12
order by gen

select gen,
coalesce(nullif(TRIM(gen),''),'n/a') as gen2
from bronze.erp_cust_az12

select gen,
len(gen) as lenght_gen,
DATALENGTH(gen) as data_lenght
from bronze.erp_cust_az12
order by gen

SELECT
    gen,
    LEN(gen) AS len_original,
    LEN(TRIM(gen)) AS len_trimmed,
    DATALENGTH(gen) AS data_lenght
FROM bronze.erp_cust_az12
WHERE gen LIKE '% ';

SELECT
    gen AS old_gen,
    TRIM(gen) AS new_gen,
    LEN(gen) AS old_length,
    LEN(TRIM(gen)) AS new_length
FROM bronze.erp_cust_az12
WHERE gen <> TRIM(gen

--==========================================================================
--Checking 'bronze.erp_loc_a101'
--==========================================================================
select cid from bronze.erp_loc_a101
where cid != TRIM(cid)

select distinct cntry from silver.erp_loc_a101;

SELECT distinct
    cntry,
    LEN(cntry) AS len_original,
    LEN(TRIM(cntry)) AS len_trimmed,
    DATALENGTH(cntry) AS data_lenght
FROM silver.erp_loc_a101;
--==========================================================================
--Checking 'bronze.erp_px_cat_g1v2'
--==========================================================================
select * from silver.crm_prd_info
where cat_id not in(select cat_id from bronze.erp_px_cat_g1v2);

select cat from bronze.erp_px_cat_g1v2
where cat != TRIM(cat);

select distinct cat,
LEN(cat) as len_cat
from bronze.erp_px_cat_g1v2;

select subcat from bronze.erp_px_cat_g1v2
where subcat != TRIM(subcat);

select distinct subcat
from bronze.erp_px_cat_g1v2;

select distinct maintenance
from bronze.erp_px_cat_g1v2;

select distinct maintenance,
LEN(maintenance) as lenght
from silver.erp_px_cat_g1v2;

--==========================================================================
--Checking for Gold Layer 
--Checking for dimension customers
--==========================================================================
select cst_id from silver.crm_cust_info
where cst_id in (select sls_cst_id from silver.crm_sales_details)

select cst_key from silver.crm_cust_info
where cst_key not in (select cid from silver.erp_cust_az12)

select cst_key from silver.crm_cust_info
where cst_key not in (select cid from silver.erp_loc_a101)
--==========================================================================
--Checking for Gold Layer 
--Checking for dimension products
--==========================================================================
select prd_key from silver.crm_prd_info
where prd_key not in (select sls_prd_key from silver.crm_sales_details);

select cat_id from silver.crm_prd_info
where cat_id not in (select id from silver.erp_px_cat_g1v2)



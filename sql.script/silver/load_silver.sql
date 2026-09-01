create or alter procedure silver.load_silver as
Begin
  declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
  begin try
	set @batch_start_time = GETDATE();
    PRINT'=============================================';
	PRINT'Loading Silver layre';
	PRINT'=============================================';

	PRINT'---------------------------------------------';
	PRINT 'Loading CRM tables';
    PRINT'---------------------------------------------';

	set @start_time = GETDATE()
	PRINT'>>Truncating table: silver.crm_cust_info';
	truncate table silver.crm_cust_info;
	PRINT'>>Inserting data into: silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_martial_status,
	cst_gender,
	cst_create_date)

	select 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	case when UPPER(TRIM(cst_martial_status)) = 'S' then 'Single'
		 when UPPER(TRIM(cst_martial_status)) = 'M' then 'Married'
		 else 'n/a'
	end cst_martial_status,
	case when UPPER(TRIM(cst_gender)) = 'F' then 'Female'
		 when UPPER(TRIM(cst_gender)) = 'M' then 'Male'
		 else 'n/a'
	end cst_gender,
	cst_create_date
	from(
	select *,
	ROW_NUMBER () over (partition by cst_id order by cst_create_date desc) flag
	from bronze.crm_cust_info
	where cst_id is not null
	) sub  where flag = 1
	set @end_time = GETDATE()
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>------------------------------------------------------------------------';

--------------------------------------------------------------------------------------------------------------------------	
    set @start_time = GETDATE()
	PRINT'>>Truncating table: silver.crm_prd_info';
	truncate table silver.crm_prd_info;
	PRINT'>>Inserting data into: silver.crm_prd_info';
	insert into silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_name,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)
	select
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
	prd_name,
	ISNULL(prd_cost,0) as prd_cost,
	CASE TRIM(UPPER(prd_line))
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		 ELSE 'n\a'
	END prd_line,
	CAST(prd_start_dt as date) as prd_start_dt,
	CAST(LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
	from bronze.crm_prd_info
	set @end_time = GETDATE()
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>------------------------------------------------------------------------';

--------------------------------------------------------------------------------------------------------------------------	
    set @start_time = GETDATE()
	PRINT'>>Truncating table: silver.crm_sales_details_info';
	truncate table silver.crm_sales_details;
	PRINT'>>Inserting data into: silver.crm_sales_details';
	insert into silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cst_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)

	select 
	sls_ord_num,
	sls_prd_key,
	sls_cst_id,
	CASE
	   WHEN sls_order_dt = 0 or LEN(sls_order_dt) !=8 THEN NULL
	   ELSE CAST(CAST(sls_order_dt as nvarchar) as date)
	END as sls_order_dt,
	CASE
	   WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) !=8 THEN NULL
	   ELSE CAST(CAST(sls_ship_dt as nvarchar) as date)
	END as sls_ship_dt,
	CASE
	   WHEN sls_due_dt = 0 or LEN(sls_ship_dt) !=8 THEN NULL
	   ELSE CAST(CAST(sls_due_dt as nvarchar) as date)
	END as sls_due_dt,
	case 
		when sls_sales != sls_quantity * ABS(sls_price) or sls_sales <= 0 or sls_sales is null
		then sls_quantity * ABS(sls_price)
		else sls_sales
	end as sls_sales,
	sls_quantity,
	case 
		 when sls_price <= 0 or sls_price is null
		 then sls_sales / sls_quantity
		 else sls_price
	end as sls_price
	from bronze.crm_sales_details
	set @end_time = GETDATE()
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>------------------------------------------------------------------------';

--------------------------------------------------------------------------------------------------------------------------	
	PRINT'----------------------------------------------------------------------------------';
	PRINT'Loading ERP tables';
	PRINT'----------------------------------------------------------------------------------';

	set @start_time = GETDATE()
	PRINT'>>Truncating table: silver.erp_cust_az12 ';
	truncate table silver.erp_cust_az12 ;
	PRINT'>>Inserting data into: silver.erp_cust_az12 ';
	insert into silver.erp_cust_az12 
	(cid,bdate,gen)
	select
	CASE
		WHEN cid like 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
		ELSE cid
	END AS cid,
	CASE 
		WHEN bdate > GETDATE() THEN NULL
		ELSE bdate
	END AS bdate,
	gen
	from bronze.erp_cust_az12

	UPDATE bronze.erp_cust_az12
	SET gen = TRIM(gen)
	WHERE gen <> TRIM(gen);
	set @end_time = GETDATE()
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>------------------------------------------------------------------------';

--------------------------------------------------------------------------------------------------------------------------	
    set @start_time = GETDATE()
	PRINT'>>Truncating table: silver.erp_loc_a101';
	truncate table silver.erp_loc_a101;
	PRINT'>>Inserting data into: silver.erp_loc_a101';
	insert into silver.erp_loc_a101
	(cid,cntry)
	select 
	replace(cid,'-',''),
	CASE 
		WHEN TRIM(cntry) = '' THEN 'n/a'
		WHEN TRIM(cntry) in ('US','USA') THEN 'United States'
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		ELSE cntry
	END AS cntry
	from bronze.erp_loc_a101;

	UPDATE silver.erp_loc_a101
	SET cntry = TRIM(cntry);
	set @end_time = GETDATE()
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>------------------------------------------------------------------------';

----------------------------------------------------------------------------------------------------------------------
    set @start_time = GETDATE()
	PRINT'>>Truncating table: silver.erp_px_cat_g1v2 ';
	truncate table silver.erp_px_cat_g1v2 ;
	PRINT'>>Inserting data into: silver.erp_px_cat_g1v2 ';
	insert into silver.erp_px_cat_g1v2 
	(id,cat,subcat,maintenance)
	select 
	id,
	cat,
	subcat,
	TRIM(maintenance)
	from bronze.erp_px_cat_g1v2;

	update silver.erp_px_cat_g1v2
	set maintenance = TRIM(maintenance);
	
	set @end_time = GETDATE()
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>------------------------------------------------------------------------';
	set @batch_end_time = GETDATE();
	PRINT'============================================================='
	PRINT'Loading Silver layer is completed';
	PRINT'Total duration:- ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + ' seconds';
	PRINT'============================================================='
  end try
  begin catch
    PRINT'==============================================================='
	PRINT'Error occured during loading bronze layer'
	PRINT'Error message' + Error_message();
	PRINT'Error message' + cast (Error_number() as nvarchar);
	PRINT'Error message' + cast (Error_state() as nvarchar);
	PRINT'==============================================================='
  end catch

End;

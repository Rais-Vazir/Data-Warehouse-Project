--This scripts insert and load data into the 'bronze' schema from source, use store procedure to load the data
--this scripts truncates the bronze table before loadind data.

create or alter procedure bronze.load_bronze as
begin
  declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
  begin try
  set @batch_start_time = GETDATE();
    PRINT'=============================================';
	PRINT'Loading bronze layre';
	PRINT'=============================================';

	PRINT'---------------------------------------------';
	PRINT 'Loading CRM tables';
    PRINT'---------------------------------------------';

	set @start_time = GETDATE();
	PRINT'>>Truncating table: bronze.crm_cust_info';
	truncate table bronze.crm_cust_info;
	PRINT'>>Inserting data into: bronze.crm_cust_info';
	bulk insert bronze.crm_cust_info
	from "C:\Users\raisk\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv"
	with ( firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a',
	tablock);
	set @end_time = GETDATE();
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>---------------------------------------------------';

	set @start_time = GETDATE ();
	PRINT'>>Truncating table: bronze.crm_prd_info';
	truncate table bronze.crm_prd_info;
    PRINT'>>Inserting data into: bronze.crm_prd_info';
	bulk insert bronze.crm_prd_info
	from "C:\Users\raisk\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv"
	with ( firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a',
	tablock);
	set @end_time = GETDATE();
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>---------------------------------------------------------';

	set @start_time = GETDATE();
	PRINT'>>Truncating table: bronze.crm_sales_details';
	truncate table bronze.crm_sales_details;
    PRINT'>>Inserting data into: bronze.crm_sales_details';
	bulk insert bronze.crm_sales_details 
	from "C:\Users\raisk\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv"
	with ( firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a',
	tablock);
	set @end_time = GETDATE();
    PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>--------------------------------------------------------------------------';


	PRINT'----------------------------------------------------------------------------------';
	PRINT'Loading ERP tables';
	PRINT'----------------------------------------------------------------------------------';

	set @start_time = GETDATE();
	PRINT'>>Truncating table:bronze.erp_loc_a101';
	truncate table bronze.erp_loc_a101;
	PRINT'>>Inserting data into:bronze.erp_loc_a101';
	bulk insert bronze.erp_loc_a101 
	from "C:\Users\raisk\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv"
	with ( firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a',
	tablock);
	set @end_time = GETDATE();
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>--------------------------------------------------------------------------';


	set @start_time = GETDATE();
	PRINT'>>Truncating table:bronze.erp_cust_az12';
	truncate table bronze.erp_cust_az12;
	PRINT'>>inserting data into:bronze.erp_cust_az12';
	bulk insert bronze.erp_cust_az12 
	from "C:\Users\raisk\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv"
	with ( firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a',
	tablock);
	set @end_time = GETDATE();
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>----------------------------------------------------------------------------';


	set @start_time = GETDATE();
	PRINT'>>Truncating table:bronze.erp_px_cat_g1v2';
	truncate table bronze.erp_px_cat_g1v2;
	PRINT'>>inserting data into:bronze.erp_px_cat_g1v2';
	bulk insert bronze.erp_px_cat_g1v2 
	from "C:\Users\raisk\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv"
	with ( firstrow = 2,
	fieldterminator = ',',
	rowterminator = '0x0a',
    tablock);
	set @end_time = GETDATE();
	PRINT'>> Load duration:- ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
	PRINT'>>------------------------------------------------------------------------';

	set @batch_end_time = GETDATE();
	PRINT'============================================================='
	PRINT'Loading bronze layer is completed';
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
end

exec bronze.load_bronze

select * from bronze.crm_prd_info
select * from silver.crm_prd_info

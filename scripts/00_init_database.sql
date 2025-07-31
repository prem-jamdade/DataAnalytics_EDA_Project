-- ===============================================
-- Script to set up the 'DataWarehouseAnalytics' database.
-- It creates the database, defines the 'gold' schema,
-- creates necessary dimension and fact tables,
-- and loads data from external CSV files using BULK INSERT.
-- ===============================================

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database if it exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the new database
CREATE DATABASE DataWarehouseAnalytics;
GO

-- Switch context to the new database
USE DataWarehouseAnalytics;
GO

-- Create 'gold' schema for data warehousing layer
CREATE SCHEMA gold;
GO

-- Create customer dimension table
CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

-- Create product dimension table
CREATE TABLE gold.dim_products(
	product_key int,
	product_id int,
	product_number nvarchar(50),
	product_name nvarchar(50),
	category_id nvarchar(50),
	category nvarchar(50),
	subcategory nvarchar(50),
	maintenance nvarchar(50),
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

-- Create sales fact table
CREATE TABLE gold.dim_sales(
	order_number nvarchar(50),
	product_key int, -- FK to dim_products
	customer_key int, -- FK to dim_customers
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

-- Load data from CSV files into the dimension and fact tables
-- Clear any existing records before inserting (optional for staging)
TRUNCATE TABLE gold.dim_customers;
GO

-- Load customer data
BULK INSERT gold.dim_customers
FROM 'C:\Users\91845\Desktop\SQL\DataAnalytics_EDA_Project\Datasets\csv-files\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2, -- Skip header
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

-- Load product data
BULK INSERT gold.dim_products
FROM 'C:\Users\91845\Desktop\SQL\DataAnalytics_EDA_Project\Datasets\csv-files\gold.dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_sales;
GO

-- Load sales data
BULK INSERT gold.dim_sales
FROM 'C:\Users\91845\Desktop\SQL\DataAnalytics_EDA_Project\Datasets\csv-files\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

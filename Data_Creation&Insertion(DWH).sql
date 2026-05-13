CREATE DATABASE BikeStoreDB;
USE BikeStoreDB;

CREATE TABLE staging_bike_sales (
    Sale_ID INT,
    Date DATE,
    Year INT,
    Month INT,
    Month_Name VARCHAR(20),
    Quarter VARCHAR(5),
    Season VARCHAR(10),
    Day_of_Week VARCHAR(20),
    Customer_ID INT,
    Customer_Age INT,
    Customer_Gender VARCHAR(10),
    Age_Group VARCHAR(20),
    Bike_Model VARCHAR(50),
    Price FLOAT,
    Quantity INT,
    Total_Revenue FLOAT,
    Revenue_Category VARCHAR(10),
    Store_Location VARCHAR(50),
    Salesperson_ID INT,
    Salesperson_Name VARCHAR(100),
    Payment_Method VARCHAR(20)
);
BULK INSERT staging_bike_sales
FROM 'D:\Study\Data Analysi_NTI\final project\dataset\bike_sales_cleaned.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- ============================================================
-- DIM DATE
-- ============================================================
CREATE TABLE dim_date (
    Date_ID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATE,
    Year INT,
    Month INT,
    Month_Name VARCHAR(20),
    Quarter VARCHAR(5),
    Season VARCHAR(10),
    Day_of_Week VARCHAR(20)
);

INSERT INTO dim_date (Date, Year, Month, Month_Name, Quarter, Season, Day_of_Week)
SELECT DISTINCT Date, Year, Month, Month_Name, Quarter, Season, Day_of_Week
FROM staging_bike_sales;

-- ============================================================
-- DIM CUSTOMER
-- ============================================================
CREATE TABLE dim_customer (
    Customer_ID INT PRIMARY KEY,
    Customer_Age INT,
    Customer_Gender VARCHAR(10),
    Age_Group VARCHAR(20)
);

INSERT INTO dim_customer
SELECT DISTINCT Customer_ID, Customer_Age, Customer_Gender, Age_Group
FROM staging_bike_sales;

-- ============================================================
-- DIM BIKE
-- ============================================================
CREATE TABLE dim_bike (
    Bike_ID INT IDENTITY(1,1) PRIMARY KEY,
    Bike_Model VARCHAR(50)
);

INSERT INTO dim_bike (Bike_Model)
SELECT DISTINCT Bike_Model
FROM staging_bike_sales;

-- ============================================================
-- DIM STORE
-- ============================================================
CREATE TABLE dim_store (
    Store_ID INT IDENTITY(1,1) PRIMARY KEY,
    Store_Location VARCHAR(50)
);

INSERT INTO dim_store (Store_Location)
SELECT DISTINCT Store_Location
FROM staging_bike_sales;

-- ============================================================
-- DIM PAYMENT
-- ============================================================
CREATE TABLE dim_payment (
    Payment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Payment_Method VARCHAR(20)
);

INSERT INTO dim_payment (Payment_Method)
SELECT DISTINCT Payment_Method
FROM staging_bike_sales;

-- ============================================================
-- DIM SALESPERSON
-- ============================================================
CREATE TABLE dim_salesperson (
    Salesperson_ID INT PRIMARY KEY,
    Salesperson_Name VARCHAR(100)
);

INSERT INTO dim_salesperson
SELECT DISTINCT Salesperson_ID, Salesperson_Name
FROM staging_bike_sales;

-- تأكد
SELECT 'dim_date' AS tbl, COUNT(*) AS rows FROM dim_date UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer UNION ALL
SELECT 'dim_bike', COUNT(*) FROM dim_bike UNION ALL
SELECT 'dim_store', COUNT(*) FROM dim_store UNION ALL
SELECT 'dim_payment', COUNT(*) FROM dim_payment UNION ALL
SELECT 'dim_salesperson', COUNT(*) FROM dim_salesperson;

-- ============================================================
-- FACT SALES
-- ============================================================
CREATE TABLE fact_sales (
    Sale_ID INT PRIMARY KEY,
    Date_ID INT FOREIGN KEY REFERENCES dim_date(Date_ID),
    Customer_ID INT FOREIGN KEY REFERENCES dim_customer(Customer_ID),
    Bike_ID INT FOREIGN KEY REFERENCES dim_bike(Bike_ID),
    Store_ID INT FOREIGN KEY REFERENCES dim_store(Store_ID),
    Payment_ID INT FOREIGN KEY REFERENCES dim_payment(Payment_ID),
    Salesperson_ID INT FOREIGN KEY REFERENCES dim_salesperson(Salesperson_ID),
    Price FLOAT,
    Quantity INT,
    Total_Revenue FLOAT,
    Revenue_Category VARCHAR(10)
);

INSERT INTO fact_sales
SELECT 
    s.Sale_ID,
    d.Date_ID,
    s.Customer_ID,
    b.Bike_ID,
    st.Store_ID,
    p.Payment_ID,
    s.Salesperson_ID,
    s.Price,
    s.Quantity,
    s.Total_Revenue,
    s.Revenue_Category
FROM staging_bike_sales s
JOIN dim_date d ON s.Date = d.Date
JOIN dim_bike b ON s.Bike_Model = b.Bike_Model
JOIN dim_store st ON s.Store_Location = st.Store_Location
JOIN dim_payment p ON s.Payment_Method = p.Payment_Method;

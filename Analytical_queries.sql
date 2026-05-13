-- ============================================================
-- 1. SALES PERFORMANCE
-- ============================================================
USE  BikeStoreDB
-- Total Revenue
SELECT SUM(Total_Revenue) AS Total_Revenue FROM fact_sales;

-- Total Orders
SELECT COUNT(Sale_ID) AS Total_Orders FROM fact_sales;

-- Average Order Value
SELECT ROUND(AVG(Total_Revenue), 2) AS AOV FROM fact_sales;

-- Total Quantity Sold
SELECT SUM(Quantity) AS Total_Units_Sold FROM fact_sales;
--===========================
--Business Decisions
--===========================
--الـ AOV عالي → ركز على الـ customer retention مش بس acquisition
--متوسط 3 units per order → اعمل bundle offers

-- ============================================================
-- 2. PRODUCT ANALYSIS
-- ============================================================

-- Revenue by Bike Model
SELECT 
    b.Bike_Model,
    COUNT(f.Sale_ID) AS Total_Orders,
    SUM(f.Quantity) AS Total_Units,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    ROUND(AVG(f.Price), 2) AS Avg_Price
FROM fact_sales f
JOIN dim_bike b ON f.Bike_ID = b.Bike_ID
GROUP BY b.Bike_Model
ORDER BY Total_Revenue DESC;
--===========================
--Business Decisions
--===========================
--ركز الـ marketing على Hybrid Bike لأنه الأعلى revenue
--راجع استراتيجية Mountain Bike عشان الأقل أداء
--فكر في bundle offers بين الموديلات المتقاربة

-- ============================================================
-- 3. CUSTOMER ANALYSIS
-- ============================================================

-- Revenue by Gender
SELECT 
    c.Customer_Gender,
    COUNT(f.Sale_ID) AS Total_Orders,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    ROUND(AVG(f.Total_Revenue), 2) AS AOV
FROM fact_sales f
JOIN dim_customer c ON f.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Gender
ORDER BY Total_Revenue DESC;
--===========================
--Business Decisions
--===========================
--الـ Female بتجيب أعلى revenue لأنها أكتر في الـ orders
--بس الـ Male عنده AOV أعلى يعني بيصرف أكتر في كل أوردر
--*********************************************************************
--***للـ Female ركز على الـ frequency وللـ Male ركز على الـ upselling
--*********************************************************************

-- Revenue by Age Group
SELECT 
    c.Age_Group,
    COUNT(f.Sale_ID) AS Total_Orders,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    ROUND(AVG(f.Total_Revenue), 2) AS AOV
FROM fact_sales f
JOIN dim_customer c ON f.Customer_ID = c.Customer_ID
GROUP BY c.Age_Group
ORDER BY Total_Revenue DESC;
--*********************************************************************
-- ركز على الـ Youth لأنهم الأكبر، وفكر في loyalty program للـ Senior
--*********************************************************************
-- Top 10 Customers
SELECT TOP 10
    f.Customer_ID,
    c.Customer_Gender,
    c.Age_Group,
    COUNT(f.Sale_ID) AS Total_Orders,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue
FROM fact_sales f
JOIN dim_customer c ON f.Customer_ID = c.Customer_ID
GROUP BY f.Customer_ID, c.Customer_Gender, c.Age_Group
ORDER BY Total_Revenue DESC;
--*********************************************************************
--اعمل VIP program لأعلى 100 customer، هم بيجيبوا جزء كبير من الـ revenue
--*********************************************************************

--*الـ Youth:

--أكتر في الـ orders (38,626)
--بس AOV = $7,798

--الـ Middle Age + Adult:
--أقل orders
--بس AOV أعلى يعني بيشتروا كميات أكبر في كل أوردر

--Business Decision:
--********************************************************************************************
-- Youth → ركز على frequency (خليهم يرجعوا أكتر)
-- Middle Age + Adult → ركز على upselling (بيصرفوا أكتر في كل زيارة، اديهم premium products)
--********************************************************************************************

-- ============================================================
-- 4. LOCATION ANALYSIS
-- ============================================================
use BikestoreDb
-- Revenue by City
SELECT 
    st.Store_Location,
    COUNT(f.Sale_ID) AS Total_Orders,
    SUM(f.Quantity) AS Total_Units,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    ROUND(AVG(f.Total_Revenue), 2) AS AOV
FROM fact_sales f
JOIN dim_store st ON f.Store_ID = st.Store_ID
GROUP BY st.Store_Location
ORDER BY Total_Revenue DESC;
--1. New York الأول
--أعلى revenue وأعلى AOV، ده يعني السوق في New York أقوى.
--Decision: زود الـ inventory وافتح store تاني في New York.

--2. San Antonio الأخير
--أقل revenue وأقل AOV ($7,696)، ده يعني الـ customers هناك بيصرفوا أقل.
--Decision: راجع الـ pricing strategy في San Antonio أو اعمل targeted promotions.

--3. Los Angeles عنده AOV عالي ($7,817) بس Orders أقل
--يعني الـ customers بيصرفوا كتير بس عددهم أقل.
--Decision: زود الـ marketing في LA عشان تجيب customers أكتر.


-- ============================================================
-- 5. SALESPERSON ANALYSIS
-- ============================================================

-- Top 10 Salespersons
SELECT TOP 10
    sp.Salesperson_ID,
    sp.Salesperson_Name,
    COUNT(f.Sale_ID) AS Total_Orders,
    SUM(f.Quantity) AS Total_Units,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    ROUND(AVG(f.Total_Revenue), 2) AS AOV
FROM fact_sales f
JOIN dim_salesperson sp ON f.Salesperson_ID = sp.Salesperson_ID
GROUP BY sp.Salesperson_ID, sp.Salesperson_Name
ORDER BY Total_Revenue DESC;

-- Bottom 10 Salespersons
SELECT TOP 10
    sp.Salesperson_ID,
    sp.Salesperson_Name,
    COUNT(f.Sale_ID) AS Total_Orders,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    ROUND(AVG(f.Total_Revenue), 2) AS AOV
FROM fact_sales f
JOIN dim_salesperson sp ON f.Salesperson_ID = sp.Salesperson_ID
GROUP BY sp.Salesperson_ID, sp.Salesperson_Name
ORDER BY Total_Revenue ASC;

--1. Mary Jensen الأفضل
--140 order و$1.19M revenue، دي الـ top performer.
--Decision: اعملها bonus واستخدم أسلوبها كـ best practice للباقيين.

--2. Robin Young أعلى AOV ($8,954)
--مش الأكتر في الـ orders بس بيبيع بأعلى سعر.
--Decision: اتعلم منه إزاي بيعمل upselling وعلّم الباقيين.

--3. Jeremy Turner الأسوأ
--89 order بس و$579K revenue وأقل AOV ($6,508).
--Decision: محتاج training أو coaching.

--4. الفرق بين Top و Bottom كبير
--$1.19M vs $579K يعني الـ top بيجيب ضعف الـ bottom.
--Decision: اعمل mentorship program، الـ top يساعد الـ bottom.

-- ============================================================
-- 6. TIME ANALYSIS
-- ============================================================
-- Revenue by Year
SELECT 
    d.Year,
    COUNT(f.Sale_ID) AS Total_Orders,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    ROUND(AVG(f.Total_Revenue), 2) AS AOV
FROM fact_sales f
JOIN dim_date d ON f.Date_ID = d.Date_ID
GROUP BY d.Year
ORDER BY d.Year;

-- Revenue by Quarter
SELECT 
    d.Quarter,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    COUNT(f.Sale_ID) AS Total_Orders
FROM fact_sales f
JOIN dim_date d ON f.Date_ID = d.Date_ID
GROUP BY d.Quarter
ORDER BY d.Quarter;

-- Revenue by Month
SELECT 
    d.Month,
    d.Month_Name,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    COUNT(f.Sale_ID) AS Total_Orders
FROM fact_sales f
JOIN dim_date d ON f.Date_ID = d.Date_ID
GROUP BY d.Month, d.Month_Name
ORDER BY d.Month;

-- Best Season
SELECT 
    d.Season,
    ROUND(SUM(f.Total_Revenue), 2) AS Total_Revenue,
    COUNT(f.Sale_ID) AS Total_Orders
FROM fact_sales f
JOIN dim_date d ON f.Date_ID = d.Date_ID
GROUP BY d.Season
ORDER BY Total_Revenue DESC;

--1. Revenue by Year:
--2020-2023 متقاربين (~$164M)، 2024 أقل ($120M) لأن الداتا مش كاملة.
--Decision: الشركة stable ومفيش growth أو decline واضح.

--2. Revenue by Quarter:
--Q2 الأعلى ($205M) و Q3 تاني ($204M)
--Q4 الأقل ($166M) فجأة!
--Decision: ركز الـ promotions في Q4 عشان ترفعه، Black Friday مثلاً.

--3. Revenue by Month:
--August الأعلى ($70M، 8,996 order)
--November الأقل ($54.4M، 7,008 order)
--واضح إن في peak في الصيف وdrop في الخريف
--Decision: اعمل summer campaigns وخصومات في October/November.

--4. Revenue by Season:
--Summer = Spring تقريباً (~$207M)
--Fall الأقل ($175M)
--Decision: ركز الـ inventory والـ marketing في Summer وSpring.

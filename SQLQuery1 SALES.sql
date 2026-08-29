--What is the total sales amount? 

SELECT format(SUM(Sales),'C2','en-us')AS TotalSales FROM SuperstoreSales
GO
--What is the total profit? 

SELECT format(SUM(Profit),'C2','en-us')AS TotalProfit FROM SuperstoreSales
GO
--What is the average sales value?

SELECT format(AVG(Sales),'C2','en-us')AS AverageSales FROM  SuperstoreSales
GO
--What is the average profit value? 

SELECT format(AVG(Profit),'C2','en-us')AS AverageProfit FROM SuperstoreSales
GO
--How many unique customers are there? 

SELECT COUNT(DISTINCT Customer_ID) AS UniqueCustomers FROM SuperstoreSales
GO
--How many unique products are there?

SELECT COUNT(DISTINCT Product_ID)AS UniqueProducts FROM SuperstoreSales
GO
--What is the date range of the dataset? 
SELECT MIN(Order_Date)AS StartDate,MAX(Order_Date)AS EndDate FROM SuperstoreSales
GO
--Which category has the highest total sales?
SELECT Category,
       FORMAT(SUM(Sales),'C2','EN-US') AS TotalSales
FROM SuperstoreSales
GROUP BY Category
ORDER BY SUM(Sales) DESC;
GO
--Which sub-category has the highest sales?
SELECT Sub_Category,
       FORMAT(SUM(Sales),'C2','EN-US') AS TotalSales
FROM SuperstoreSales
GROUP BY Sub_Category
ORDER BY SUM(Sales) DESC;
GO
--Which product generated the highest revenue?
SELECT Product_Name,
       FORMAT(SUM(Sales),'C2','EN-US') AS TotalRevenue
FROM SuperstoreSales
GROUP BY Product_Name
ORDER BY SUM(Sales) DESC;
GO
--Which region has the highest sales?
SELECT Region,SUM(Sales)AS TotalSales 
FROM SuperstoreSales
GROUP BY Region
ORDER BY TotalSales 
GO
--Which state has the highest sales?
SELECT DISTINCT State,FORMAT(SUM(Sales),'C2','EN-US')AS TotalSales FROM SuperstoreSales
GROUP BY State
GO
--Which categories have experienced growth or decline in sales over time?
SELECT 
Category,
MONTH(Order_Date)AS OrderMonth,
YEAR(Order_Date)AS OrderYear,
format(SUM(Sales),'C2','en-us')AS TotalSales
FROM SuperstoreSales 
GROUP BY Category , MONTH(Order_Date),
YEAR(Order_Date)
ORDER BY Category ,OrderMonth,
OrderYear DESC
GO
--How are sales distributed across different shipping modes?
SELECT Ship_Mode, FORMAT(SUM(Sales),'C2','EN-US') FROM SuperstoreSales
GROUP BY Ship_Mode
GO
--Which city has the highest sales?
SELECT City,
SUM(Sales)AS TotalSales
FROM SuperstoreSales
GROUP BY City
ORDER BY TotalSales
GO
--Which customers contribute the most to total sales?
SELECT Customer_ID,
       FORMAT(SUM(Sales),'C2','EN-US') AS TotalSales
FROM SuperstoreSales
GROUP BY Customer_ID
ORDER BY SUM(Sales) DESC;
GO

SELECT * FROM SuperstoreSales
GO
--Which products generate the highest losses?
SELECT Product_ID, SUM(Profit)AS TotalProfit FROM SuperstoreSales
WHERE Profit IS NOT NULL
GROUP BY Product_ID
ORDER BY TotalProfit
GO
--Does higher discount reduce profit?
SELECT  AVG(Profit) AS AvgProfit , Discount FROM SuperstoreSales
GROUP BY Discount
ORDER BY Discount
GO
--What is the customer retention rate?
WITH CustomerOrders AS
(
	SELECT COUNT (DISTINCT Order_ID) AS OrderCount,Customer_ID
	FROM SuperstoreSales
	GROUP BY Customer_ID
)
SELECT 
	COUNT(CASE WHEN OrderCount > 1 THEN 1 END )*100.0
	/ COUNT(*) AS RetentionRate
FROM CustomerOrders
GO
--Which customer segment contributes the most to sales and profit?
SELECT 
Segment , SUM(Sales) AS TotalSales ,
SUM(Profit) AS TotalProfit
FROM SuperstoreSales
GROUP BY Segment
GO
--Which products remain profitable despite high discounts?
SELECT  Product_ID,MAX(Profit)AS TotalProfit,AVG(Discount)AS  AvgDiscount
FROM SuperstoreSales
GROUP BY Product_ID
HAVING AVG(Discount)>= 0.15 AND SUM(Profit) > 0
ORDER BY AvgDiscount
GO
--During which periods did significant drops in sales or profit occur?
SELECT 
		YEAR(Order_Date)AS OrderYear,
	    MONTH(Order_Date)OrderMonth,
	    SUM(Sales) AS TotalSales,
        SUM(Profit) AS TotalProfit
FROM SuperstoreSales
GROUP BY YEAR(Order_Date),
	    MONTH(Order_Date)
ORDER BY OrderYear,
		OrderMonth
GO
--What is the average time between customer orders?
WITH CustomerIntervals AS
(
	SELECT 
	Customer_ID,
	DATEDIFF(DAY,LAG(Order_Date) OVER (PARTITION BY Customer_ID ORDER BY Order_Date),Order_Date)
	AS PreviousOrderDate
	FROM SuperstoreSales
)
SELECT 
AVG(CAST(PreviousOrderDate AS float)) AS AvgDaysBetweenOrders
FROM CustomerIntervals
WHERE PreviousOrderDate IS NOT NULL
GO
--Which regions have the highest number of orders?
SELECT Region,COUNT(DISTINCT Order_ID) AS CountOrders
FROM SuperstoreSales
GROUP BY Region
GO

--Which region has the best profit-to-sales ratio?
SELECT 
Region,
SUM(Profit)/SUM(Sales) AS ProfitToSalesRatio
FROM SuperstoreSales
GROUP BY Region
ORDER BY ProfitToSalesRatio DESC
GO

--Which cities have high sales but low profit, and why?
SELECT 
City,
SUM(Sales) AS TotalSales,
SUM(Profit) AS TotalProfit
FROM SuperstoreSales
GROUP BY City
ORDER BY TotalProfit
GO

--Which products should be removed from the product portfolio?
SELECT 
 Product_ID,
SUM(Sales) AS TotalSales,
SUM(Profit) AS TotalProfit
FROM SuperstoreSales
GROUP BY Product_ID 
HAVING SUM(Profit) < 0
AND SUM(Sales)< (
					SELECT AVG(ProductSales)
					FROM
        (
            SELECT SUM(Sales) AS ProductSales
            FROM SuperstoreSales
            GROUP BY Product_ID
        ) x
    )
ORDER BY TotalProfit


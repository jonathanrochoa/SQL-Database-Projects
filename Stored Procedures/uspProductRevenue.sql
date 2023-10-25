SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[uspProductRevenue]
    @ProductID NVARCHAR(10) = NULL
AS
BEGIN
 SET NOCOUNT ON;

    -- Description: This stored procedure calculates the total revenue for products.

    -- Parameters:
    -- @ProductID: Specify 'ALL' to calculate total revenue for all products. 
    --             Specify a specific ProductID to calculate total revenue for a single product.

    -- Calculate total revenue for all products or a specific product
    WITH ProductRevenueCTE AS (
        SELECT
            p.ProductId AS ProductID,
            SUM((sod.UnitPrice * (1 - sod.UnitPriceDiscount)) * sod.OrderQty) AS TotalRevenue
        FROM [YourSchemaName].[Product] AS p -- Replace 'YourSchema' with your schema name
        LEFT JOIN [YourSchemaName].[ProductCategory] AS pc ON pc.ProductCategoryID = p.ProductCategoryID
        LEFT JOIN [YourSchemaName].[SalesOrderDetail] AS sod ON sod.ProductID = p.ProductID
        WHERE @ProductID IS NULL OR (@ProductID = 'ALL' AND p.ProductID IS NOT NULL)
           OR p.ProductID = @ProductID
        GROUP BY p.ProductID
    )

    -- Return the total revenues in a result set
    SELECT
        pr.ProductID,
        p.Name,
        pr.TotalRevenue
    FROM ProductRevenueCTE AS pr
    LEFT JOIN [YourSchemaName].[Product] AS p ON p.ProductID = pr.ProductID
    WHERE pr.TotalRevenue IS NOT NULL
    ORDER BY pr.TotalRevenue DESC;
END;
GO

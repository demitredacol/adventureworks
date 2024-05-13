USE [AdventureWorks2022]
GO

/*
-- Cabeçalho e itens
SELECT	SalesOrderHeader.SalesOrderID NumeroPedido
		,SalesOrderHeader.OrderDate "Data criação"
		,SalesOrderHeader.DueDate "Prazo de entrega"
		,SalesOrderHeader.ShipDate "Data de envio"
		,SalesOrderHeader.Status CodigoStatus
		,SalesOrderHeader.CustomerID CodigoCliente
		,SalesOrderHeader.SalesPersonID CodigoVendedor
		,SalesOrderHeader.TerritoryID CodigoRegiaoVendas
		,SalesOrderHeader.ShipMethodID CodigoMetodoEnvio		
		,CASE WHEN SalesOrderHeader.CurrencyRateID IS NULL THEN 'USD' ELSE CurrencyRate.ToCurrencyCode END AS Moeda
		,CASE WHEN SalesOrderHeader.CurrencyRateID IS NULL THEN 1     ELSE CurrencyRate.AverageRate    END AS "Valor cotação moeda"
		,CASE ROW_NUMBER() OVER(PARTITION BY SalesOrderHeader.SalesOrderID ORDER BY SalesOrderDetail.SalesOrderDetailID ASC)
		      WHEN 1 THEN SalesOrderHeader.TaxAmt
			  ELSE 0 END AS "Valor total impostos do pedido"
		,CASE ROW_NUMBER() OVER(PARTITION BY SalesOrderHeader.SalesOrderID ORDER BY SalesOrderDetail.SalesOrderDetailID ASC)
		      WHEN 1 THEN SalesOrderHeader.Freight
			  ELSE 0 END "Valor total frete do pedido"
	    ,SalesOrderDetail.SalesOrderDetailID Item
		,SalesOrderDetail.ProductID CodigoProduto
		,SalesOrderDetail.OrderQty "Quantidade pedido"
		,SalesOrderDetail.UnitPrice "Preço unitário"
		,SalesOrderDetail.UnitPriceDiscount "Percentual desconto item"
		,SalesOrderDetail.LineTotal "Valor total do item"

		,SalesOrderHeader.TotalDue "Total do pedido"

		,COALESCE(Address.AddressLine1, ' ') + COALESCE(Address.AddressLine2, ' ') AS "Endereço"
		,Address.PostalCode "CEP"
		,Address.City Cidade
		,StateProvince.Name Estado
		,CountryRegion.Name "País"

		,CASE SalesOrderHeader.Status
		     WHEN 1 THEN 'Em processamento' --In process; 
			 WHEN 2 THEN 'Aprovado' --Approved; 
			 WHEN 3 THEN 'Em espera' --Backordered; 
			 WHEN 4 THEN 'Rejeitado' --Rejected; 
			 WHEN 5 THEN 'Enviado' --Shipped; 
			 WHEN 6 THEN 'Cancelado' --Cancelled
			 ELSE null END AS "Status da ordem"
  FROM Sales.SalesOrderHeader
  LEFT JOIN Sales.CurrencyRate ON SalesOrderHeader.CurrencyRateID = CurrencyRate.CurrencyRateID
  JOIN Sales.SalesOrderDetail ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID

  LEFT JOIN Person.Address       ON SalesOrderHeader.BillToAddressID = Address.AddressID
  LEFT JOIN Person.StateProvince ON Address.StateProvinceID = StateProvince.StateProvinceID
  LEFT JOIN Person.CountryRegion ON StateProvince.CountryRegionCode = CountryRegion.CountryRegionCode 
  */

SELECT ProductID "CodigoProduto", 
CAST(StartDate AS DATE) "DataInicio", 
CAST(CASE WHEN EndDate IS NULL THEN CAST(GETDATE() AS DATE) ELSE EndDate END AS DATE) "DataFim", StandardCost "Custo padrão" 
FROM Production.ProductCostHistory
UNION ALL
SELECT Product.ProductId, 
       CAST(CASE WHEN Custo.EndDate IS NULL THEN Product.SellStartDate ELSE Custo.EndDate END AS date) AS DataInicio,
	   CAST(GETDATE() AS DATE) AS DataFim,
	   Product.StandardCost
FROM Production.Product 
LEFT JOIN (SELECT ProductId, MAX(EndDate) AS EndDate
           FROM Production.ProductCostHistory
		   GROUP BY ProductId) AS Custo ON Product.ProductID = Custo.ProductId
WHERE NOT EXISTS (SELECT 1 FROM Production.ProductCostHistory WHERE Product.ProductID = ProductCostHistory.ProductID AND ProductCostHistory.EndDate IS NULL)
AND Product.StandardCost  > 0 
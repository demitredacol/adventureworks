USE [AdventureWorks2022]
GO

-- Cabe�alho e itens
SELECT	SalesOrderHeader.SalesOrderID NumeroPedido
		,SalesOrderHeader.OrderDate "Data cria��o"
		,SalesOrderHeader.DueDate "Prazo de entrega"
		,SalesOrderHeader.ShipDate "Data de envio"
		,SalesOrderHeader.Status CodigoStatus
		,SalesOrderHeader.CustomerID CodigoCliente
		,SalesOrderHeader.SalesPersonID CodigoVendedor
		,SalesOrderHeader.TerritoryID CodigoRegiaoVendas
		,SalesOrderHeader.ShipMethodID CodigoMetodoEnvio		
		,CASE WHEN SalesOrderHeader.CurrencyRateID IS NULL THEN 'USD' ELSE CurrencyRate.ToCurrencyCode END AS Moeda
		,CASE WHEN SalesOrderHeader.CurrencyRateID IS NULL THEN 1     ELSE CurrencyRate.AverageRate    END AS "Valor cota��o moeda"
		,CASE ROW_NUMBER() OVER(PARTITION BY SalesOrderHeader.SalesOrderID ORDER BY SalesOrderDetail.SalesOrderDetailID ASC)
		      WHEN 1 THEN SalesOrderHeader.TaxAmt
			  ELSE 0 END AS "Valor total impostos do pedido"
		,CASE ROW_NUMBER() OVER(PARTITION BY SalesOrderHeader.SalesOrderID ORDER BY SalesOrderDetail.SalesOrderDetailID ASC)
		      WHEN 1 THEN SalesOrderHeader.Freight
			  ELSE 0 END "Valor total frete do pedido"
	    ,SalesOrderDetail.SalesOrderDetailID Item
		,SalesOrderDetail.ProductID CodigoProduto
		,SalesOrderDetail.OrderQty "Quantidade pedido"
		,SalesOrderDetail.UnitPrice "Pre�o unit�rio"
		,SalesOrderDetail.UnitPriceDiscount "Percentual desconto item"
		,SalesOrderDetail.LineTotal "Valor total do item"

		,SalesOrderHeader.TotalDue "Total do pedido"

		,COALESCE(Address.AddressLine1, ' ') + COALESCE(Address.AddressLine2, ' ') AS "Endere�o"
		,Address.PostalCode "CEP"
		,Address.City Cidade
		,StateProvince.Name Estado
		,CountryRegion.Name "Pa�s"

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
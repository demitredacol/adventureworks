USE [AdventureWorks2022]
GO


-- Cliente
SELECT Customer.CustomerID CodigoCliente,  
       COALESCE(Person.FirstName + ' ', '') + COALESCE(Person.MiddleName + ' ', '') + COALESCE(Person.LastName, '') Cliente,
	   Endereco."Endereço", Endereco.Cidade, Endereco.CEP, Endereco.Estado, Endereco."País"
  FROM Sales.Customer
  LEFT JOIN Person.Person on Customer.PersonID = Person.BusinessEntityID
  LEFT JOIN (SELECT BusinessEntityAddress.BusinessEntityID, 
 				    COALESCE(Address.AddressLine1, ' ') + COALESCE(Address.AddressLine2, ' ') AS "Endereço",
				    Address.PostalCode "CEP",
				    Address.City Cidade, 
				    StateProvince.Name Estado, CountryRegion.Name "País"
			 FROM (SELECT BusinessEntityID, AddressID
				  FROM (SELECT BusinessEntityID, AddressID,
							   ROW_NUMBER() OVER(PARTITION BY BusinessEntityAddress.BusinessEntityID ORDER BY BusinessEntityAddress.AddressId ASC) AS XORDEM
						FROM Person.BusinessEntityAddress ) AS X
				  WHERE X.XORDEM = 1) AS BusinessEntityAddress
			 JOIN Person.Address       ON BusinessEntityAddress.AddressID = Address.AddressID
			 JOIN Person.StateProvince ON Address.StateProvinceID = StateProvince.StateProvinceID
			 JOIN Person.CountryRegion ON StateProvince.CountryRegionCode = CountryRegion.CountryRegionCode ) AS Endereco ON Person.BusinessEntityID = Endereco.BusinessEntityID
 

-- Produtos
SELECT Product.ProductId CodigoProduto, 
       Product.Name Produto, 
	   Product.SellStartDate "Data início vendas",
	   Product.DiscontinuedDate "Data descontinuado",
	   Product.StandardCost "Custo padrão",
	   ProductCategory.Name "Categoria",
       ProductSubcategory.Name "Sub categoria",
	   ProductModel.Name "Modelo"
  FROM Production.Product
  LEFT JOIN Production.ProductSubcategory ON Product.ProductSubcategoryID = ProductSubcategory.ProductSubcategoryID
  LEFT JOIN Production.ProductCategory ON ProductSubcategory.ProductCategoryID =  ProductCategory.ProductCategoryID
  LEFT JOIN Production.ProductModel ON ProductModel.ProductModelID = Product.ProductModelID
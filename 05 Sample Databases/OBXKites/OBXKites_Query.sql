
USE OBXKITES


Use OBXKites
go
Select * from vTableRowCount
go
Select ProductCategoryName, ProductCategoryDescription from ProductCategory
go
Select Code, Name from Product
go
select ProductCategoryName, Code, Name, Price, EffectiveDate
   From Product
      Join ProductCategory
         On Product.ProductCategoryID = ProductCategory.ProductCategoryID
      Join Price 
         On Product.ProductID = Price.ProductID
go
EXEC pProductCategory_FetchID '8F1D2560-7164-46CD-A5BA-DD1AA7C981A9'
go
EXEC pProductCategory_Fetch 'Kite'
go
EXEC pCustomerType_Delete 'F7AD7277-C610-401D-B0CD-F11C23231678'
go
DECLARE @Price MONEY
EXEC  pGetPrice '1001', NULL, '100', @Price output
select @Price

Select dbo.fGetPrice('1004',GetDate(),'101')

Select * from [Order]

DECLARE @OrderNumber CHAR(15)
EXEC  pOrder_AddNew '101', '120', 'OBX', NULL, @OrderNumber output
select @OrderNumber
go
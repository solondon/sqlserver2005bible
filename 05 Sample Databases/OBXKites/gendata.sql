

DECLARE 
  @OrderNumber INT,
  @ContactNumber INT,
  @ProductNumber INT,
  @Quantity INT,
  @OrderDetailCount INT,
  @GenCount INT

SET @GenCount = 0
While @GenCount < 90000
  Begin 
      SET @GenCount = @GenCount + 1 
      
      -- gen order header
      SELECT @OrderNumber = Max(OrderNumber) + 1 FROM [Order]
      SET @ContactNumber = (Select CAST ((RAND()*21) AS INT)+100 )
      EXEC pOrder_AddNew '101', '120', 'CH', NULL, @OrderNumber output
  
      -- gen 1-5 order details 
      SET @OrderDetailCount = 0
      WHILE @OrderDetailCount < (Select CAST ((RAND()*5) AS INT)+1 )
        BEGIN 
          SET @OrderDetailCount = @OrderDetailCount + 1 

          SET @ProductNumber = (Select CAST ((RAND()*55) AS INT)+1000 )
          SET @Quantity = (Select CAST ((RAND()*5) AS INT)+1 )
          EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 3, NULL, NULL, NULL
    
        END 
  
  END


SELECT Count(*) FROM [Order]



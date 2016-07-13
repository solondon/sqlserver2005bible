
-----------------------------------------------------------
-- SQL Server 2000 Bible 
-- Hungry Minds 
-- Paul Nielsen

-- OBX Kites Sample Datebase - Benchmark
-- May 16, 2002

-- this script loads the population data 
-- and then executes a series of queries

-- The following script must be run prior to this script:
-- OBXKites_Create

Use OBXKites


DBCC dropcleanbuffers
DBCC freeproccache

SET NOCOUNT ON

Delete OrderDetail
Delete [Order]
Delete Contact
Delete CustomerType
Delete Price
Delete Product
Delete ProductCategory
Delete Location
Delete OrderPriority

SET Statistics IO off
SET Statistics Time off 


Declare @Duration DateTime
Set @Duration = GetDate()

-----------------------------------------------------------
-----------------------------------------------------------
-- Product Categories

EXEC pProductCategory_AddNew 'Kite', 'a variety of kites, from simple to stunt, to Chinese, to novelty kites'
EXEC pProductCategory_AddNew 'Accessory', 'kite flying accessories' 
EXEC pProductCategory_AddNew 'Video', 'stunt kite contexts and lessons, and Outer Banks videos' 
EXEC pProductCategory_AddNew 'Book', 'Outer Banks books'
EXEC pProductCategory_AddNew 'Material', 'Kite construction material' 
EXEC pProductCategory_AddNew 'OBX', 'OBX stuff' 
EXEC pProductCategory_AddNew 'Toy', 'Kids stuff'
EXEC pProductCategory_AddNew 'Clothing', 'OBX t-shirts, hats, jackets'

-----------------------------------------------------------
-- Products
EXEC pProduct_AddNew 'Kite', '1001', 'Basic Box Kite 21 inch',''
EXEC pProduct_AddNew 'Kite', '1002', 'Dragon Flight',''
EXEC pProduct_AddNew 'Kite', '1003', 'Sky Dancer',''
EXEC pProduct_AddNew 'Kite', '1004', 'Rocket Kite',''
EXEC pProduct_AddNew 'Kite', '1005', 'Eagle Wings',''
EXEC pProduct_AddNew 'Kite', '1006', 'Chinese 6" Kite',''
EXEC pProduct_AddNew 'Kite', '1007', 'Grand Spiral',''
EXEC pProduct_AddNew 'Kite', '1008', 'Sky Dancer 2',''
EXEC pProduct_AddNew 'Kite', '1009', 'Air Writer 36',''
EXEC pProduct_AddNew 'Kite', '1010', 'Air Writer 48',''
EXEC pProduct_AddNew 'Kite', '1011', 'Air Writer 66',''
EXEC pProduct_AddNew 'Kite', '1012', 'Falcon F-16',''
EXEC pProduct_AddNew 'Kite', '1013', 'Eagle F-15',''
EXEC pProduct_AddNew 'Kite', '1014', 'Pirate Ship in the Sky',''
EXEC pProduct_AddNew 'Kite', '1015', 'Raider in the Sky',''
EXEC pProduct_AddNew 'Kite', '1016', 'Original Diamond Kite',''
EXEC pProduct_AddNew 'Kite', '1017', 'Competition 36"',''
EXEC pProduct_AddNew 'Kite', '1018', 'Competition Pro 48"',''
EXEC pProduct_AddNew 'Kite', '1019', 'Grand Daddy',''
EXEC pProduct_AddNew 'Kite', '1020', 'Black Ghost',''
EXEC pProduct_AddNew 'Accessory', '1021', 'Short Twirl',''
EXEC pProduct_AddNew 'Accessory', '1022', 'Long Twirl',''
EXEC pProduct_AddNew 'Accessory', '1023', 'Short Streamer',''
EXEC pProduct_AddNew 'Accessory', '1024', 'Long Streamer',''
EXEC pProduct_AddNew 'Accessory', '1025', 'Night Glow Streamers',''
EXEC pProduct_AddNew 'Accessory', '1026', 'Handle',''
EXEC pProduct_AddNew 'Accessory', '1027', 'Third Line Release',''
EXEC pProduct_AddNew 'Accessory', '1028', 'High Performance Line',''
EXEC pProduct_AddNew 'Accessory', '1029', 'Kite Bag',''
EXEC pProduct_AddNew 'Accessory', '1030', 'Kite Repair Kit',''
EXEC pProduct_AddNew 'Video', '1031', 'Basic Kite Flight',''
EXEC pProduct_AddNew 'Video', '1032', '2001 July 4th Competition',''
EXEC pProduct_AddNew 'Video', '1033', '2000 Wright Brothers Memorial FlyIn',''
EXEC pProduct_AddNew 'Video', '1034', 'Advanced Acrobatics',''
EXEC pProduct_AddNew 'Video', '1035', 'Kite Demos',''
EXEC pProduct_AddNew 'Book', '1036', 'Adventures in the OuterBanks',''
EXEC pProduct_AddNew 'Book', '1037', 'Wright Brothers Kite Designs',''
EXEC pProduct_AddNew 'Book', '1038', 'The Lighthouses of the Outer Banks',''
EXEC pProduct_AddNew 'Book', '1039', 'Outer Banks Map',''
EXEC pProduct_AddNew 'Book', '1040', 'Kiters Guide to the Outer Banks',''
EXEC pProduct_AddNew 'Material', '1041', 'Kite Fabric #6',''
EXEC pProduct_AddNew 'Material', '1042', 'Kite Fabric #8',''
EXEC pProduct_AddNew 'Material', '1043', 'Super Strutts',''
EXEC pProduct_AddNew 'OBX', '1044', 'OBX Car Bumper Sticker',''
EXEC pProduct_AddNew 'OBX', '1045', 'OBX Car Window Decal',''
EXEC pProduct_AddNew 'OBX', '1046', 'OBX Postcard set',''
EXEC pProduct_AddNew 'OBX', '1047', 'OBX Light Houses Poster',''
EXEC pProduct_AddNew 'OBX', '1048', 'OBX/Kite Poster',''
EXEC pProduct_AddNew 'Toy', '1049', 'Wright Brothers Model Plane',''
EXEC pProduct_AddNew 'Toy', '1050', 'Spinner Hilo',''
EXEC pProduct_AddNew 'Clothing', '1051', 'Cape Hatteras T-Shirt',''
EXEC pProduct_AddNew 'Clothing', '1052', 'OBX T-Shirt',''
EXEC pProduct_AddNew 'Clothing', '1053', 'OBX BallCap',''
EXEC pProduct_AddNew 'Clothing', '1054', 'Go Fly a Kite T-Shirt',''
EXEC pProduct_AddNew 'Clothing', '1055', 'OBX National Seashore BallCap',''

-----------------------------------------------------------
-- Prices

--Basic Box Kite 21 inch
EXEC pPrice_AddNew 1001, NULL, 14.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Basic Box Kite 21 inch', 15.95, '06/01/2002'
EXEC pPrice_AddNew NULL, 'Basic Box Kite 21 inch', 17.95, '7/20/2002'

--Dragon Flight
EXEC pPrice_AddNew 1002, NULL, 26.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Dragon Flight', 29.95, '5/20/2002'
EXEC pPrice_AddNew NULL, 'Dragon Flight', 31.95, '5/20/2003'

--Sky Dancer
EXEC pPrice_AddNew NULL, 'Sky Dancer', 18.95, '05/01/2001'
EXEC pPrice_AddNew 1003, NULL, 19.95, '5/20/2002'
EXEC pPrice_AddNew 1003, NULL, 20.95, '5/20/2003'

--Rocket Kite
EXEC pPrice_AddNew 1004, NULL, 29.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Rocket Kite', 32.95, '05/01/2002'
EXEC pPrice_AddNew NULL, 'Rocket Kite', 35.95, '5/20/2003'

--Eagle Wings
EXEC pPrice_AddNew 1005, NULL, 65.00, '05/01/2001'
EXEC pPrice_AddNew 1005, NULL, 69.00, '05/01/2002'

--Chinese 6 foot Kite
EXEC pPrice_AddNew 1006, NULL, 119.95, '05/01/2001'
EXEC pPrice_AddNew 1006, NULL, 125.95, '5/20/2002'
EXEC pPrice_AddNew 1006, NULL, 131.95, '5/20/2003'

--Grand Spiral
EXEC pPrice_AddNew NULL, 'Grand Spiral', 12.95, '05/01/2001'
EXEC pPrice_AddNew 1007, NULL, 15.95, '5/20/2002'
EXEC pPrice_AddNew 1007, NULL, 16.45, '5/20/2003'

--Sky Dancer 2
EXEC pPrice_AddNew 1008, NULL, 26.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Sky Dancer 2', 28.95, '05/01/2002'
EXEC pPrice_AddNew NULL, 'Sky Dancer 2', 29.95, '5/20/2003'

--Air Writer 36
EXEC pPrice_AddNew 1009, NULL, 54.95, '05/01/2001'
EXEC pPrice_AddNew 1009, NULL, 57.95, '05/01/2002'
EXEC pPrice_AddNew 1009, NULL, 59.95, '07/14/2002'
EXEC pPrice_AddNew 1009, NULL, 62.95, '05/01/2003'

--Air Writer 48
EXEC pPrice_AddNew 1010, NULL, 74.95, '05/01/2001'
EXEC pPrice_AddNew 1010, NULL, 77.95, '05/20/2002'
EXEC pPrice_AddNew 1010, NULL, 81.95, '05/20/2003'

--Air Writer 66
EXEC pPrice_AddNew 1011, NULL, 112.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Air Writer 66', 119.95, '5/20/2002'
EXEC pPrice_AddNew NULL, 'Air Writer 66', 125.95, '5/20/2003'

--Falcon F-16
EXEC pPrice_AddNew 1012, NULL, 49.95, '05/01/2001'

--Eagle F-15
EXEC pPrice_AddNew 1013, NULL, 49.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Eagle F-15', 52.95, '5/20/2002'

--Pirate Ship in the Sky
EXEC pPrice_AddNew 1014, NULL, 79.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Pirate Ship in the Sky', 74.95, '05/01/2002'
EXEC pPrice_AddNew NULL, 'Pirate Ship in the Sky', 77.95, '5/20/2003'

--Raider in the Sky
EXEC pPrice_AddNew 1015, NULL, 22.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Raider in the Sky', 19.95, '5/20/2002'

--Original Diamond Kite
EXEC pPrice_AddNew 1016, NULL, 9.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Original Diamond Kite', 8.95, '07/01/2002'
EXEC pPrice_AddNew NULL, 'Original Diamond Kite', 8.95, '07/08/2002'
EXEC pPrice_AddNew NULL, 'Original Diamond Kite', 9.95, '05/01/2003'
EXEC pPrice_AddNew NULL, 'Original Diamond Kite', 10.95, '5/20/2004'

--Competition 36"
EXEC pPrice_AddNew 1017, NULL, 225.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Competition 36"', 245.95, '5/20/2003'

--Competition Pro 48"
EXEC pPrice_AddNew 1018, NULL, 284.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Competition Pro 48"', 264.95, '05/01/2002'
EXEC pPrice_AddNew NULL, 'Competition Pro 48"', 173.95, '5/20/2003'

--Grand Daddy
EXEC pPrice_AddNew NULL, 'Grand Daddy', 29.95, '05/01/2001'
EXEC pPrice_AddNew 1019, NULL, 27.95, '5/20/2002'

--Black Ghost
EXEC pPrice_AddNew 1020, NULL, 29.95, '05/01/2001'

--Short Twirl
EXEC pPrice_AddNew 1021, NULL, 1.95, '05/01/2001'

--Long Twirl
EXEC pPrice_AddNew 1022, NULL, 2.65, '05/01/2001'
EXEC pPrice_AddNew 1022, NULL, 2.95, '5/20/2002'

--Short Streamer
EXEC pPrice_AddNew 1023, NULL, 1.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Short Streamer', 2.95, '5/20/2002'

--Long Streamer
EXEC pPrice_AddNew 1024, NULL, 1.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Long Streamer', 2.45, '5/20/2002'

--Night Glow Streamers
EXEC pPrice_AddNew 1025, NULL, 5.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Night Glow Streamers', 6.95, '5/20/2002'
EXEC pPrice_AddNew NULL, 'Night Glow Streamers', 7.95, '5/20/2003'

--Handle
EXEC pPrice_AddNew 1026, NULL, 8.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Handle', 9.95, '5/20/2003'

--Third Line Release
EXEC pPrice_AddNew 1027, NULL, 15.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Third Line Release', 13.45, '5/20/2002'
EXEC pPrice_AddNew NULL, 'Third Line Release', 14.95, '5/20/2003'

--High Performance Line
EXEC pPrice_AddNew 1028, NULL, 10.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'High Performance Line', 12.95, '5/20/2002'

--Kite Bag
EXEC pPrice_AddNew 1029, NULL, 8.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Kite Bag', 9.95, '5/20/2002'
EXEC pPrice_AddNew NULL, 'Kite Bag', 11.95, '5/20/2003'

--Kite Repair Kit
EXEC pPrice_AddNew 1030, NULL, 1.95, '05/01/2001'

--Basic Kite Flight
EXEC pPrice_AddNew 1031, NULL, 6.95, '05/01/2001'
EXEC pPrice_AddNew 1031, NULL, 7.95, '05/20/2002'
EXEC pPrice_AddNew 1031, NULL, 6.95, '07/01/2002'
EXEC pPrice_AddNew 1031, NULL, 7.95, '07/10/2002'
EXEC pPrice_AddNew 1031, NULL, 8.95, '05/20/2003'

--2001 July 4th Competition
EXEC pPrice_AddNew 1032, NULL, 19.95, '05/01/2001'

--2000 Wright Brothers Memorial FlyIn
EXEC pPrice_AddNew 1033, NULL, 19.95, '05/01/2001'


--Advanced Acrobatics
EXEC pPrice_AddNew 1034, NULL, 19.95, '05/01/2001'

--Kite Demos
EXEC pPrice_AddNew 1035, NULL, 19.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Kite Demos', 14.95, '5/20/2002'

--Adventures in the OuterBanks
EXEC pPrice_AddNew 1036, NULL, 7.95, '05/01/2001'
EXEC pPrice_AddNew 1036, NULL, 8.95, '07/01/2003'

--Wright Brothers Kite Designs
EXEC pPrice_AddNew NULL, 'Wright Brothers Kite Designs', 29.95, '5/20/2002'

--The Lighthouses of the Outer Banks
EXEC pPrice_AddNew 1038, NULL, 14.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'The Lighthouses of the Outer Banks', 16.95, '5/20/2002'

--Outer Banks Map
EXEC pPrice_AddNew 1039, NULL, 2.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Outer Banks Map', 3.95, '5/20/2002'

--Kiters Guide to the Outer Banks
EXEC pPrice_AddNew 1040, NULL, 9.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Kiters Guide to the Outer Banks', 8.95, '5/20/2002'

--Kite Fabric #6
EXEC pPrice_AddNew 1041, NULL, .95, '05/01/2001'

--Kite Fabric #8
EXEC pPrice_AddNew 1042, NULL, .95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Kite Fabric #8', 1.05, '5/20/2002'

--Super Strutts
EXEC pPrice_AddNew 1043, NULL, 1.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Super Strutts', 12.25, '5/20/2002'

--OBX Car Bumper Sticker
EXEC pPrice_AddNew 1044, NULL,  .75, '05/01/2001'

--OBX Car Window Decal
EXEC pPrice_AddNew 1045, NULL, .75, '5/20/2001'
EXEC pPrice_AddNew 1045, NULL, .95, '5/20/2002'

--OBX Postcard set
EXEC pPrice_AddNew 1046, NULL, 1.95, '05/01/2001'

--OBX Light Houses Poster
EXEC pPrice_AddNew 1047, NULL, 6.95, '05/01/2001'
EXEC pPrice_AddNew 1047, NULL, 7.95, '5/20/2002'
EXEC pPrice_AddNew 1047, NULL, 8.95, '5/20/2003'

--OBX/Kite Poster
EXEC pPrice_AddNew 1048, NULL, 6.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'OBX/Kite Poster', 7.95, '5/20/2002'

--Wright Brothers Model Plane
EXEC pPrice_AddNew 1049, NULL, 12.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Wright Brothers Model Plane', 14.95, '5/20/2002'

--Spinner Hilo
EXEC pPrice_AddNew 1050, NULL, 4.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Spinner Hilo', 5.45, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Spinner Hilo', 5.95, '5/20/2002'

--Cape Hatteras T-Shirt
EXEC pPrice_AddNew 1051, NULL, 14.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Cape Hatteras T-Shirt', 16.95, '5/20/2002'

--OBX T-Shirt
EXEC pPrice_AddNew 1052, NULL, 14.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'OBX T-Shirt', 16.95, '5/20/2002'

--OBX BallCap
EXEC pPrice_AddNew 1054, NULL, 11.95, '05/01/2001'

--Go Fly a Kite T-Shirt
EXEC pPrice_AddNew 1054, NULL, 8.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'Go Fly a Kite T-Shirt', 9.95, '5/20/2002'

--OBX National Seashore BallCap
EXEC pPrice_AddNew 1055, NULL, 13.95, '05/01/2001'
EXEC pPrice_AddNew NULL, 'OBX National Seashore BallCap', 14.95, '5/20/2002'


-----------------------------------------------------------
-- Customer Types
EXEC pCustomerType_AddNew 'Preferred', .10
EXEC pCustomerType_AddNew 'Wholesale', .15
EXEC pCustomerType_AddNew 'Retail',0,1 -- set this CustomerType to the default

-- Contacts
EXEC pContact_AddNew '101', 'Smith', 'Ulisius', NULL, 'Preferred'
EXEC pContact_AddNew '102', 'Adams', 'Terri', NULL, 'Preferred'
EXEC pContact_AddNew '103', 'Reagan', 'Steve', NULL, 'Preferred'
EXEC pContact_AddNew '104', 'Franklin', 'Rondey', NULL, 'Preferred'
EXEC pContact_AddNew '105', 'Dowdry', 'Quin', NULL, 'Preferred'
EXEC pContact_AddNew '106', 'Grant', 'Peter', 'Southern Beach', 'Wholesale'
EXEC pContact_AddNew '107', 'Smith', 'Oscar', 'Cape Hatteras General Store', 'Wholesale'
EXEC pContact_AddNew '108', 'Hanks', 'Nickolas', 'Norfolk Kite Flight', 'Wholesale'
EXEC pContact_AddNew '109', 'James', 'Mike', 'Boston Kites', 'Wholesale'
EXEC pContact_AddNew '110', 'Kennedy', 'Lisa', 'Wright Brothers Memorial Store', 'Wholesale'
EXEC pContact_AddNew '111', 'Williams', 'Kid', NULL, 'Retail'
EXEC pContact_AddNew '112', 'Quincy', 'Jennifer', NULL, 'Retail'
EXEC pContact_AddNew '113', 'Laudry', 'Irene', NULL, 'Retail'
EXEC pContact_AddNew '114', 'Nelson', 'Harry', NULL, 'Retail'
EXEC pContact_AddNew '115', 'Miller', 'Ginger', NULL, 'Retail'
EXEC pContact_AddNew '116', 'Jamison', 'Frank', NULL -- use the default CustomerType
EXEC pContact_AddNew '117', 'Andrews', 'Ed', NULL
EXEC pContact_AddNew '118', 'Boston', 'Dave', NULL
EXEC PContactSetEmployee '118'
EXEC pContact_AddNew '119', 'Harrison', 'Charlie', NULL
EXEC PContactSetEmployee '119'
EXEC pContact_AddNew '120', 'Earl', 'Betty', NULL
EXEC PContactSetEmployee '120'
EXEC pContact_AddNew '121', 'Zing', 'Chei', NULL

-----------------------------------------------------------
-- Location
EXEC pLocation_AddNew 'CH', 'Cape Hatteras', 1
EXEC pLocation_AddNew 'Clt', 'Charlotte', 1
EXEC pLocation_AddNew 'ElC', 'Elizabeth City', 1
EXEC pLocation_AddNew 'JR', 'Jockey''s Ridge', 1
EXEC pLocation_AddNew 'KDH', 'Kill Devil Hills', 1
EXEC pLocation_AddNew 'W', 'Warehouse', 0

-----------------------------------------------------------
-- Order Entry
EXEC pOrderPriority_AddNew 'Rush', '1', '1'

DECLARE @OrderNumber INT

--Order 1
EXEC  pOrder_AddNew 
   @ContactCode = '101', 
   @EmployeeCode = '120', 
   @LocationCode = 'CH', 
   @OrderDate=NULL, 
   @OrderNumber = @OrderNumber output

EXEC pOrder_SetPriority @OrderNumber, '1'

EXEC pOrder_AddItem 
   @OrderNumber = @OrderNumber, -- must be a valid, open order. Get OrderNumber from pOrder_AddNew
   @Code = '1002', -- if NULL then non-stock Product text description
   @NonStockProduct = NULL,
   @Quantity = 12, -- required
   @UnitPrice = NULL, -- if Null then the sproc will lookup the correct current price for the customer
   @ShipRequestDate = '11/15/01', -- if NULL then today
   @ShipComment = NULL

-- Order 2
EXEC pOrder_AddNew '101', '120', 'CH', NULL, @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 3, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1003', NULL, 5, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1004', NULL, 2, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1044', NULL, 1, NULL, NULL, NULL
-- Order 3
EXEC pOrder_AddNew '102', '120', 'CH', NULL, @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 3, NULL, NULL, NULL
EXEC pOrder_SetPriority @OrderNumber, '1'

-- Order 4
EXEC pOrder_AddNew '103', '119', 'JR', '11/15/01', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1051', NULL, 6, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1012', NULL, 5, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 4, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1023', NULL, 3, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1024', NULL, 2, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1023', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1044', NULL, 1, NULL, NULL, NULL
--Order 5 
EXEC pOrder_AddNew '101', '118', 'CH', '11/15/01', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1032', NULL, 2, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1043', NULL, 3, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1044', NULL, 120, .50, '12/1/01', 'bulk ship to Mateo'
-- Order 6
EXEC  pOrder_AddNew '102', '120', 'CH', NULL, @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1055', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1044', NULL, 1, NULL, NULL, NULL
-- Order 7
EXEC  pOrder_AddNew '103', '119', 'JR', NULL, @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 2, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 12, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1044', NULL, 1, NULL, NULL, NULL
-- Order 8
EXEC  pOrder_AddNew '104', '118', 'CH', '11/15/01', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1002', '11/21/01', 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1002', '11/21/01', 2, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1044', NULL, 1, NULL, NULL, NULL
-- Order 9
EXEC  pOrder_AddNew '105', '121', 'KDH', NULL, @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 3, NULL ,NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1044', NULL, 1, NULL, NULL, NULL
-- Order 10
EXEC  pOrder_AddNew '106', '121', 'KDH', NULL, @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 2, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1052', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1054', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1044', NULL, 1, NULL, NULL, NULL



Select * from [Order]
Select * from OrderDetail
Select dbo.fGetPrice ('1002',GetDate(), '101')
Select @OrderNumber
--Select * from Price Join Product On Price.ProductID = Product.ProductID Where ProductCode = '1003'

-------------------------------------------------------

Select ProductCategoryName, ProductCategoryDescription from ProductCategory

Select Code, ProductName from Product

select ProductCategoryName, Code, ProductName, Price, EffectiveDate
   From Product
      Join ProductCategory
         On Product.ProductCategoryID = ProductCategory.ProductCategoryID
      Join Price 
         On Product.ProductID = Price.ProductID

EXEC pProductCategory_FetchID '8F1D2560-7164-46CD-A5BA-DD1AA7C981A9'

-- EXEC pProductCategory_Fetch 'Kite'

-- EXEC pCustomerType_Delete 'F7AD7277-C610-401D-B0CD-F11C23231678'

DECLARE @Price MONEY
EXEC  pGetPrice '1001', NULL, '100', @Price output
select @Price

Select dbo.fGetPrice('1004',GetDate(),'101')

Select * from [Order]

SELECT TOP 3 PERCENT Code, ProductName, Price, 
  CONVERT(VARCHAR(10),EffectiveDate,1) AS PriceDate
  FROM Product
    JOIN Price ON Product.ProductID = Price.ProductID
  ORDER BY Price DESC

SELECT TOP 3 Code, ProductName, Price, 
  CONVERT(VARCHAR(10),EffectiveDate,1) AS PriceDate
  FROM Product
    JOIN Price ON Product.ProductID = Price.ProductID
  ORDER BY Price

--the raw data sorted by price
SELECT Productname, Price 
  FROM Product
    JOIN Price ON Product.ProductID = Price.ProductID
  ORDER BY Price

SELECT CustomerTypeName,
  CASE [Default] 
    WHEN 1 THEN 'default type'
    WHEN 0 THEN 'possible'
      ELSE '-'
  END AS AssignStatus
  FROM CustomerType


SELECT DISTINCT OrderNumber 
  FROM [Order]
    JOIN OrderDetail
      ON [Order].OrderID = OrderDetail.OrderID
  WHERE Quantity BETWEEN 12 AND 24


SELECT ProductName 
  FROM Product 
  WHERE ProductName LIKE  'Air%'

SELECT ProductName 
  FROM Product 
  WHERE ProductName LIKE  '[a-d]%'

-- searching for a string that contains a wildcard character

SELECT Code, ProductName 
  FROM Product 
  WHERE ProductName LIKE '%F[-]15%'

SELECT Code, ProductName 
  FROM Product 
  WHERE ProductName LIKE '%F&-15%' ESCAPE '&'


-- Multiple where conditions

SELECT Code, ProductName 
  FROM Product 
  WHERE ProductName LIKE  'Air%' 
    OR Code BETWEEN '1018' AND '1020'
    AND ProductName LIKE '%G%'

SELECT Code, ProductName 
  FROM Product 
  WHERE ( ProductName LIKE  'Air%' 
    OR Code BETWEEN '1018' AND '1020' ) 
    AND ProductName LIKE '%G%'


SELECT SUM(Quantity) AS QuantitySold,
    SUM(Quantity*UnitPrice) AS DollarSold
  FROM dbo.OrderDetail
    JOIN dbo.[Order] 
      ON [Order].OrderID = OrderDetail.OrderID
  WHERE OrderDate Between '1/1/2001' AND '12/31/2001 11:59.998PM'

SELECT DatePart(yy,OrderDate) AS [Year], SUM(Quantity) AS QuantitySold,
    SUM(Quantity*UnitPrice) AS DollarSold
  FROM dbo.OrderDetail
    JOIN dbo.[Order] 
      ON [Order].OrderID = OrderDetail.OrderID
  GROUP BY DatePart(yy,OrderDate)

-- multiple group by columns
SELECT DatePart(yy,OrderDate)  AS [Year], 
    ProductCategoryName, SUM(Quantity) AS QuantitySold,
    SUM(Quantity*UnitPrice) AS DollarSold
  FROM dbo.OrderDetail
    JOIN dbo.[Order] 
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
    JOIN dbo.ProductCategory
      ON Product.ProductCategoryID =
           ProductCategory.ProductCategoryID
  GROUP BY DatePart(yy,OrderDate),ProductCategoryName

-- Polished
SELECT DatePart(yy,OrderDate)  AS [Year], 
    ProductCategoryName, SUM(Quantity) AS QuantitySold,
    SUM(Quantity*UnitPrice) AS DollarSold
  FROM dbo.OrderDetail
    JOIN dbo.[Order] 
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
    JOIN dbo.ProductCategory
      ON Product.ProductCategoryID =
           ProductCategory.ProductCategoryID
    JOIN dbo.Contact
      ON [Order].ContactID = Contact.ContactID
  WHERE Contact.IsEmployee = 0 
  GROUP BY DatePart(yy,OrderDate),ProductCategoryName
  HAVING SUM(Quantity) > 2
  ORDER BY SUM(Quantity*UnitPrice) DESC


SELECT  
    CASE Grouping(ProductCategoryName) 
      WHEN 0 THEN ProductCategoryName
      WHEN 1 THEN 'All Products' 
    END AS ProductCategory, 
    SUM(Quantity) AS QuantitySold,
    SUM(Quantity*UnitPrice) AS DollarSold
  FROM dbo.OrderDetail
    JOIN dbo.[Order] 
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
    JOIN dbo.ProductCategory
      ON Product.ProductCategoryID =
           ProductCategory.ProductCategoryID
  GROUP BY ProductCategoryName 
    WITH ROLLUP
  ORDER BY ISNULL(ProductCategoryName, 'zzz')



SELECT ContactCode, LastName
  FROM dbo.Contact
  ORDER BY ContactCode

SELECT Contact.ContactCode, Contact.ContactID, 
    [Order].ContactID, [Order].OrderNumber
  FROM dbo.Contact
    JOIN dbo.[Order] 
      ON [Order].ContactID = Contact.ContactID
  ORDER BY ContactCode

-- another example inner join:
USE OBXKites
SELECT LastName, FirstName, ProductName
  FROM dbo.Contact
    JOIN dbo.[Order] 
      ON Contact.ContactID = [Order].ContactID
    JOIN dbo.OrderDetail
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
    JOIN dbo.ProductCategory
      ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
  WHERE ProductCategoryName = 'Kite'
  ORDER BY LastName, FirstName

-- Legacy Join
SELECT Contact.ContactCode, Contact.ContactID, 
    [Order].ContactID, [Order].OrderNumber
  FROM dbo.Contact, dbo.[Order]
  WHERE [Order].ContactID = Contact.ContactID
  ORDER BY ContactCode

-- Left Outer Join
SELECT ContactCode, OrderNumber
  FROM dbo.Contact
    LEFT OUTER JOIN dbo.[Order] 
      ON [Order].ContactID = Contact.ContactID
  ORDER BY ContactCode


SELECT OrderNumber, OrderPriorityName
  FROM dbo.[Order]
    Left Outer Join dbo.OrderPriority
    ON [Order].OrderPriorityID = OrderPriority.OrderPriorityID


SELECT ProductName 
  FROM dbo.Product
  WHERE ProductCategoryID
    = (Select ProductCategoryID 
          FROM dbo.ProductCategory 
          Where ProductCategoryName = 'Kite')

SELECT ProductName
  FROM dbo.Product
    JOIN dbo.ProductCategory
       ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
  Where ProductCategoryName = 'Kite'


-- Subqueries as expressions

-- Column Expression
SELECT ProductCategoryName, SUM(Quantity * UnitPrice) AS Sales, 
     Cast(SUM(Quantity * UnitPrice) /
         (SELECT SUM(Quantity * UnitPrice) FROM OrderDetail) *100 AS NUMERIC(4,2)) 
         AS PercentOfSales
  FROM dbo.OrderDetail
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
    JOIN dbo.ProductCategory
      ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
  GROUP BY ProductCategoryName
  ORDER BY Count(*) DESC

-- Subqueries as Lists

SELECT ProductName 
  FROM dbo.Product
  WHERE ProductID IN
    -- 4. Find all the products sold in orders with kites
    (SELECT ProductID 
      FROM dbo.OrderDetail
      WHERE OrderID IN 
      -- 3. Find the Kite Orders
      (SELECT OrderID  -- Find the Orders with Kites
        FROM dbo.OrderDetail 
        WHERE ProductID IN 
          -- 2. Find the Kite Products
          (SELECT ProductID  
            FROM dbo.Product       
            WHERE ProductCategoryID = 
               -- 1. Find the Kite category
               (Select ProductCategoryID 
                 FROM dbo.ProductCategory 
                 Where ProductCategoryName 
                    = 'Kite' ) ) ) )

SELECT ProductName 
  FROM dbo.Product
  WHERE ProductID IN
    -- 4. Find all the products sold in orders with kites
    (SELECT ProductID 
      FROM dbo.OrderDetail
      WHERE OrderID IN 
      -- 3. Find the Kite Orders
      (SELECT OrderID  -- Find the Orders with Kites
        FROM dbo.OrderDetail 
        WHERE ProductID IN 
          -- 2. Find the Kite Products
          (SELECT ProductID  
            FROM dbo.Product       
            WHERE ProductCategoryID = 
               -- 1. Find the Kite category
               (Select ProductCategoryID 
                 FROM dbo.ProductCategory 
                 Where ProductCategoryName 
                    = 'Kite' ) ) ) )
        AND ProductID NOT IN 
          (SELECT ProductID  
            FROM dbo.Product       
            WHERE ProductCategoryID = 
               (Select ProductCategoryID 
                 FROM dbo.ProductCategory 
                 Where ProductCategoryName 
                    = 'Kite' ) ) 

SELECT Distinct Product.ProductName
  FROM dbo.Product
    JOIN dbo.OrderDetail OrderRow
      ON Product.ProductID = OrderRow.ProductID
    JOIN dbo.OrderDetail KiteRow
      ON OrderRow.OrderID = KiteRow.OrderID
    JOIN dbo.Product Kite
      ON KiteRow.ProductID = Kite.ProductID
    JOIN dbo.ProductCategory
      ON Kite.ProductCategoryID = ProductCategory.ProductCategoryID
  Where ProductCategoryName  = 'Kite'

SELECT Distinct Product.ProductName
  FROM dbo.Product
    JOIN dbo.OrderDetail OrderRow
      ON Product.ProductID = OrderRow.ProductID
    JOIN dbo.OrderDetail KiteRow
      ON OrderRow.OrderID = KiteRow.OrderID
    JOIN dbo.Product Kite
      ON KiteRow.ProductID = Kite.ProductID
    JOIN dbo.ProductCategory
      ON Kite.ProductCategoryID = ProductCategory.ProductCategoryID
      AND Product.ProductCategoryID != Kite.ProductCategoryID
Where ProductCategoryName  = 'Kite'   


SELECT Code, SUM(Quantity) AS QuantitySold
  FROM dbo.OrderDetail
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
  GROUP BY Code

SELECT Product.Code, Product.ProductName, 
    Sales.QuantitySold 
  FROM dbo.Product
  JOIN (SELECT ProductID, SUM(Quantity) AS QuantitySold
             FROM dbo.OrderDetail
             GROUP BY ProductID) Sales
    ON Product.ProductID = Sales.ProductID
  ORDER BY Code


-- DECLARE @OrderNumber INT

-- First Person orders exactly all toys 
EXEC  pOrder_AddNew 
   @ContactCode = '110', 
   @EmployeeCode = '120', 
   @LocationCode = 'CH', 
   @OrderDate='6/1/2002', 
   @OrderNumber = @OrderNumber output

EXEC pOrder_AddItem 
   @OrderNumber = @OrderNumber, -- must be a valid, open order. Get OrderNumber from pOrder_AddNew
   @Code = '1049', -- if NULL then non-stock Product text description
   @NonStockProduct = NULL,
   @Quantity = 1, -- required
   @UnitPrice = NULL, -- if Null then the sproc will lookup the correct current price for the customer
   @ShipRequestDate = NULL, -- if NULL then today
   @ShipComment = NULL

EXEC pOrder_AddItem @OrderNumber, '1050', NULL, 1, NULL, NULL, NULL

-- Second Person - has ordered exactly all toys - 1050 twice
EXEC pOrder_AddNew '111', '119', 'JR', '6/1/2002', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1049', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1050', NULL, 1, NULL, NULL, NULL

EXEC pOrder_AddNew '111', '119', 'JR', '6/1/2002', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1050', NULL, 1, NULL, NULL, NULL

-- Third Person - has order all toys plus some others
EXEC pOrder_AddNew '112', '119', 'JR', '6/1/2002', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1049', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1050', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1001', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 1, NULL, NULL, NULL

-- Fourth Person - has order one toy
EXEC pOrder_AddNew '113', '119', 'JR', '6/1/2002', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1049', NULL, 1, NULL, NULL, NULL

SELECT * 
   FROM dbo.[order] 
   WHERE OrderDate = '6/1/2002'

--Relational Division with remainder
-- Is number of toys ordered...
SELECT Contact.ContactCode 
  FROM dbo.Contact
    JOIN dbo.[Order]
      ON Contact.ContactID = [Order].ContactID
    JOIN dbo.OrderDetail
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
   JOIN dbo.ProductCategory 
      ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
  WHERE ProductCategory.ProductCategoryName = 'Toy'
  GROUP BY Contact.ContactCode
  HAVING  COUNT(DISTINCT Product.Code) = 
-- equal to number of toys available?
           (SELECT Count(Code) 
             FROM dbo.Product 
               JOIN dbo.ProductCategory 
                 ON Product.ProductCategoryID 
                   = ProductCategory.ProductCategoryID 
            WHERE ProductCategory.ProductCategoryName = 'Toy')

-- Exact Relational Division
-- Is number of all products ordered...
SELECT Contact.ContactCode  
  FROM dbo.Contact
    JOIN dbo.[Order]
      ON Contact.ContactID = [Order].ContactID
    JOIN dbo.OrderDetail
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
   JOIN dbo.ProductCategory P1
      ON Product.ProductCategoryID = P1.ProductCategoryID
   JOIN 
       -- and number of toys ordered
       (SELECT Contact.ContactCode, Product.Code  
          FROM dbo.Contact
            JOIN dbo.[Order]
              ON Contact.ContactID = [Order].ContactID
            JOIN dbo.OrderDetail
              ON [Order].OrderID = OrderDetail.OrderID
            JOIN dbo.Product
              ON OrderDetail.ProductID = Product.ProductID
           JOIN dbo.ProductCategory
              ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
           WHERE ProductCategory.ProductCategoryName = 'Toy') ToysOrdered
     ON Contact.ContactCode = ToysOrdered.ContactCode
  GROUP BY Contact.ContactCode
  HAVING  COUNT(DISTINCT Product.Code) = 
    -- equal to number of toys available?
           (SELECT Count(Code) 
             FROM dbo.Product 
               JOIN dbo.ProductCategory 
                 ON Product.ProductCategoryID 
                   = ProductCategory.ProductCategoryID 
            WHERE ProductCategory.ProductCategoryName = 'Toy')
    -- AND equal to the total number of any product ordered?
    AND COUNT(DISTINCT ToysOrdered.Code) =
           (SELECT Count(Code) 
             FROM dbo.Product 
               JOIN dbo.ProductCategory 
                 ON Product.ProductCategoryID 
                   = ProductCategory.ProductCategoryID 
            WHERE ProductCategory.ProductCategoryName = 'Toy')



 



Select 'Duration:', DateDiff(ms, @Duration, Getdate())

USE Tempdb


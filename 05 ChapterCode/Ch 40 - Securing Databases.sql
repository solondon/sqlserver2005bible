-----------------------------------------------------------
-- SQL Server 2000 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 40 - Securing Databases

-----------------------------------------------------------
-----------------------------------------------------------



-----------------------------------------------------
-- Server Security

-- Check the authentication mode
EXEC xp_loginconfig 'login mode'

-- Adding a New Windows Login
EXEC sp_grantlogin 'XPS\Joe'

-- Removing a Windows Login
EXEC sp_revokelogin 'XPS\Joe'

-- Denying a Windows Login
EXEC sp_denylogin 'XPS\Joe'

-- Setting the Default Database
EXEC sp_defaultdb 'Sam', 'OBXKites'

-- Orphaned Windows Users
EXEC sp_validatelogins

SELECT * from sys.server_principals 


-- SQL Server Logins
EXEC sp_addlogin 'Sam', 'myoldpassword', 'OBXKites'

EXEC sp_helplogins

SELECT Name, SID 
  FROM sys.server_principals 
  WHERE Name = 'Sam'

-- Updating a Password
EXEC sp_password 'myoldpassword', 'mynewpassword', 'Sam'

-- Removing a Login
EXEC sp_droplogin 'Sam'

-- Setting the default db
EXEC sp_defaultdb 'Sam', 'OBXKites'

----------------------------------------------------------
-- Database Security

-- Guest Logins
EXEC sp_adduser 'Guest'


-- Granting Access Using T-SQL Code
USE Family

EXEC sp_grantdbaccess 'Noli\Lauren', 'LRN'

EXEC sp_revokedbaccess 'LRN'

-- Fixed Database Roles

EXEC sp_addsrvrolemember  'Noli\Lauren', 'sysadmin'

-- Droppign a user from a server fixed role

EXEC sp_dropsrvrolemember  'Noli\Lauren', 'sysadmin'

SELECT pm.name, pr.name 
  FROM sys.server_principals pm
    JOIN sys.server_role_members rm
      ON pm.Principal_ID = rm.member_principal_id
    JOIN sys.server_principals pr
      ON pr.Principal_ID = rm.role_principal_id


-- Testing conflicting database roles 
EXEC sp_addlogin 'Joe'
USE Family
EXEC sp_grantdbaccess 'Joe'

-----------------------------------------------------------
- Object Security
-- Setting Object Permissions
USE Family
GRANT Select ON Person TO Joe

GRANT All ON marriage TO Public

GRANT Select ON Person to Joe WITH GRANT OPTION

GRANT Select, Update ON Person to Guest, LRN

REVOKE All ON Marriage FROM Public

DENY Select ON Person TO Joe, Public

-- Managing Standard Roles

EXEC sp_addrole 'Manager'

EXEC sp_droprole 'Manager'

EXEC sp_addrolemember 'Manager', Joe

EXEC sp_dropRoleMember  'Manager', Joe

-- Ownership

EXEC sp_changeobjectowner Person, Joe


----------------------------------------------------
-- Cryptography

-- The SQL Server-Crypto Hierarchy
CREATE MASTER KEY
  ENCRYPTION BY PASSWORD = 'P@$rw0rD';


-- Encrypting with a Passphrase
CREATE TABLE CCard (
  CCardID INT IDENTITY PRIMARY KEY NOT NULL,
  CustomerID INT NOT NULL, 
  CreditCardNumber VARBINARY(128),
  Expires CHAR(4)
  );
INSERT CCard(CustomerID, CreditCardNumber, Expires)
  VALUES(1,EncryptbyPassPhrase('Passphrase', '12345678901234567890'), '0808');

SELECT * 
  FROM CCard
  WHERE CustomerID = 1;

SELECT CCardID, CustomerID,
  CONVERT(VARCHAR(20), DecryptByPassPhrase('Password', CreditCardNumber)),
      Expires
  FROM CCard
  WHERE CustomerID = 1;
--
INSERT CCard(CustomerID, CreditCardNumber, Expires)
  VALUES(3,EncryptbyPassPhrase('Passphrase','12123434565678788989', 
      1, 'hardCoded Authenticator'), '0808');

SELECT CCardID, CustomerID, 
  CONVERT(VARCHAR(20),DecryptByPassPhrase('Passphrase', CreditCardNumber, 
      1, 'hardCoded Authenticator')), Expires 
  FROM CCard
  WHERE CustomerID = 3;

-- Encrypting with a Symmetric Key
CREATE SYMMETRIC KEY CCardKey
WITH ALGORITHM = TRIPLE_DES
ENCRYPTION BY PASSWORD = 'P@s$wOrD';

OPEN SYMMETRIC KEY CCardKey
  DECRYPTION BY PASSWORD = 'P@s$wOrD';

INSERT CCard(CustomerID, CreditCardNumber, Expires)
  VALUES(1,EncryptbyKey(Key_GUID('CCardKey'),'11112222333344445555'), '0808');


SELECT CCardID, CustomerID, 
  CONVERT(varchar(20), DecryptbyKey(CreditCardNumber)) as CreditCardNumber, 
    Expires 
  FROM CCard
  WHERE CustomerID = 7;

CLOSE SYMMETRIC KEY CCardKey

-- Using Asymmetric Keys
CREATE ASYMMETRIC KEY AsyKey
  WITH ALGORITHM = RSA_512
  ENCRYPTION BY PASSWORD = 'P@s$w0rD'; 


CREATE ASYMMETRIC KEY AsyKey
  FROM FILE  = ' C:\SQLServerBIble\AsyKey.key'
  ENCRYPTION BY PASSWORD = 'P@s$w0rD'; 


------------------------------------------------
-- Preventing SQL Injection

SELECT * 
  FROM Customers 
  WHERE CustomerID = '123'; Delete OrderDetail --'

SELECT * 
  FROM Customers 
  WHERE CustomerID = '123' or 1=1 --'

-- Password? What Password?
SELECT UserID 
  FROM Users 
  WHERE UserName = 'Joe' --' AND Password = 'who cares' 

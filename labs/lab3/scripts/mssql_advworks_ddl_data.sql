USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'adventureworks')
BEGIN
    CREATE DATABASE adventureworks;
END
GO

USE adventureworks;
GO

DROP TABLE IF EXISTS salesorderheader;
DROP TABLE IF EXISTS salesorderdetail;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS person;
GO

-- 3. Copy all required tables from AdventureWorks
SELECT * INTO [salesorderheader] FROM [AdventureWorks2017].sales.[salesorderheader];
SELECT * INTO [salesorderdetail] FROM [AdventureWorks2017].sales.[salesorderdetail];

SELECT * INTO customer FROM [AdventureWorks2017].sales.customer;

SELECT * INTO address FROM [AdventureWorks2017].person.address;

SELECT businessentityid, persontype, namestyle, title, firstname, middlename, lastname, suffix, emailpromotion, rowguid, modifieddate
INTO person FROM [AdventureWorks2017].person.person;
GO
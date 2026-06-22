
-- create database and tables for lab04
use master;
go
drop database if exists lab04db
go
create database lab04db
go
use lab04db
go

-- copy raw tables from northwind3
select * into lab04db.dbo.product_history
from northwind.dbo.product_history

select * into lab04db.dbo.categories
from northwind.dbo.categories

-- setup table from adventureworks
create table saleshistory(
id int identity(1,1) not null primary key,
salesorderid int not null,
salesorderdetailid int not null,
carriertrackingnumber nvarchar(25) null,
orderqty smallint not null,
productid int not null,
specialofferid int not null,
unitprice money not null,
unitpricediscount money not null,
linetotal numeric(38, 6) not null,
rowguid uniqueidentifier not null,
modifieddate datetime not null
)

declare @i int = 1;
while @i <= 100
begin
insert into saleshistory
select *
from adventureworks2017.sales.salesorderdetail;
set @i += 1;
end
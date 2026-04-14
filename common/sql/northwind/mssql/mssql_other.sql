-- drop tables

drop table orderhist
go

drop table sales
go

drop table produce
go

drop table buyers
go

-- cereate tables

create table orderhist
(
    productid int not null,
    orderid   int not null,
    quantity  int not null
)
go

create table buyers
(
    buyer_id   int      not null,
    buyer_name nvarchar(25) not null
)
go

create table sales
(
    buyer_id int not null,
    prod_id  int not null,
    qty      int not null
)
go

create table produce
(
    prod_id   int      not null,
    prod_name nvarchar(25) not null
)
go

-- insert data

-- joindb

INSERT INTO BUYERS (BUYER_ID, BUYER_NAME) VALUES (1, 'Adam Barr');
INSERT INTO BUYERS (BUYER_ID, BUYER_NAME) VALUES (2, 'Sean Chai');
INSERT INTO BUYERS (BUYER_ID, BUYER_NAME) VALUES (3, 'Eva Corets');
INSERT INTO BUYERS (BUYER_ID, BUYER_NAME) VALUES (4, 'Erin O''Melia');


INSERT INTO PRODUCE (PROD_ID, PROD_NAME) VALUES (1, 'Apples');
INSERT INTO PRODUCE (PROD_ID, PROD_NAME) VALUES (2, 'Pears');
INSERT INTO PRODUCE (PROD_ID, PROD_NAME) VALUES (3, 'Oranges');
INSERT INTO PRODUCE (PROD_ID, PROD_NAME) VALUES (4, 'Bananas');
INSERT INTO PRODUCE (PROD_ID, PROD_NAME) VALUES (5, 'Peaches');


INSERT INTO SALES (BUYER_ID, PROD_ID, QTY) VALUES (1, 2, 15);
INSERT INTO SALES (BUYER_ID, PROD_ID, QTY) VALUES (1, 3, 5);
INSERT INTO SALES (BUYER_ID, PROD_ID, QTY) VALUES (4, 1, 37);
INSERT INTO SALES (BUYER_ID, PROD_ID, QTY) VALUES (3, 5, 11);
INSERT INTO SALES (BUYER_ID, PROD_ID, QTY) VALUES (4, 2, 1003);

-- orderhist
INSERT INTO ORDERHIST (PRODUCTID, ORDERID, QUANTITY) VALUES (1, 1, 5);
INSERT INTO ORDERHIST (PRODUCTID, ORDERID, QUANTITY) VALUES (1, 2, 10);
INSERT INTO ORDERHIST (PRODUCTID, ORDERID, QUANTITY) VALUES (2, 1, 10);
INSERT INTO ORDERHIST (PRODUCTID, ORDERID, QUANTITY) VALUES (2, 2, 25);
INSERT INTO ORDERHIST (PRODUCTID, ORDERID, QUANTITY) VALUES (3, 1, 15);
INSERT INTO ORDERHIST (PRODUCTID, ORDERID, QUANTITY) VALUES (3, 2, 30);
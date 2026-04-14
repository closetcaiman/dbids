
create table region
(
    regionid          int   not null
        constraint pk_region
            primary key,
    regiondescription char(50) not null
)
go


create table territories
(
    territoryid          nvarchar(20) not null
        constraint pk_territories
            primary key,
    territorydescription char(50)    not null,
    regionid             int      not null
        constraint fk_territories_region
            references region
)
go


create table categories
(
    categoryid   int      not null
        constraint pk_categories
            primary key,
    categoryname nvarchar(15) not null,
    description  nvarchar(300),
    picture      ntext
)
go

create table suppliers
(
    supplierid   int      not null
        constraint pk_suppliers
            primary key,
    companyname  nvarchar(40) not null,
    contactname  nvarchar(30),
    contacttitle nvarchar(30),
    address      nvarchar(60),
    city         nvarchar(15),
    region       nvarchar(15),
    postalcode   nvarchar(10),
    country      nvarchar(15),
    phone        nvarchar(24),
    fax          nvarchar(24),
    homepage     nvarchar(200)
)
go

create table products
(
    productid       int      not null
        constraint pk_products
            primary key,
    productname     nvarchar(40) not null,
    supplierid      int
        constraint fk_products_suppliers
            references suppliers,
    categoryid      int
        constraint fk_products_categories
            references categories,
    quantityperunit nvarchar(20),
    unitprice       money
        constraint ck_products_unitprice
            check ((unitprice >= 0)),
    unitsinstock    int
        constraint ck_unitsinstock
            check ((unitsinstock >= 0)),
    unitsonorder    int
        constraint ck_unitsonorder
            check ((unitsonorder >= 0)),
    reorderlevel    int
        constraint ck_reorderlevel
            check ((reorderlevel >= 0)),
    discontinued    bit   not null
)
go

create table shippers
(
    shipperid   int      not null
        constraint pk_shippers
            primary key,
    companyname nvarchar(40) not null,
    phone       nvarchar(24)
)
go

create table customers
(
    customerid   char(5)     not null
        constraint pk_customers
            primary key,
    companyname  nvarchar(40) not null,
    contactname  nvarchar(30),
    contacttitle nvarchar(30),
    address      nvarchar(60),
    city         nvarchar(15),
    region       nvarchar(15),
    postalcode   nvarchar(10),
    country      nvarchar(15),
    phone        nvarchar(24),
    fax          nvarchar(24)
)
go

create table employees
(
    employeeid      int      not null
        constraint pk_employees
            primary key,
    lastname        nvarchar(20) not null,
    firstname       nvarchar(10) not null,
    title           nvarchar(30),
    titleofcourtesy nvarchar(25),
    birthdate       date,
    hiredate        date,
    address         nvarchar(60),
    city            nvarchar(15),
    region          nvarchar(15),
    postalcode      nvarchar(10),
    country         nvarchar(15),
    homephone       nvarchar(24),
    extension       nvarchar(4),
    photo           image,
    notes           nvarchar(600),
    reportsto       int
        constraint fk_employees_employees
            references employees,
    photopath       nvarchar(255)
)
go

create table employeeterritories
(
    employeeid  int      not null
        constraint fk_empterri_employees
            references employees,
    territoryid nvarchar(20) not null
        constraint fk_empterri_territories
            references territories,
    constraint pk_empterritories
        primary key (employeeid, territoryid)
)
go

create table customerdemographics
(
    customertypeid char(10) not null
        constraint pk_customerdemographics
            primary key,
    customerdesc   ntext
)
go

create table customercustomerdemo
(
    customerid     char(5)  not null
        constraint fk_customerdemo_customers
            references customers,
    customertypeid char(10) not null
        constraint fk_customerdemo
            references customerdemographics,
    constraint pk_customerdemo
        primary key (customerid, customertypeid)
)
go

create table orders
(
    orderid        int not null
        constraint pk_orders
            primary key,
    customerid     char(5)
        constraint fk_orders_customers
            references customers,
    employeeid     int
        constraint fk_orders_employees
            references employees,
    territoryid    nvarchar(20)
        constraint fk_orders_territories
            references territories,
    orderdate      date,
    requireddate   date,
    shippeddate    date,
    shipvia        int
        constraint fk_orders_shippers
            references shippers,
    freight        money,
    shipname       nvarchar(40),
    shipaddress    nvarchar(60),
    shipcity       nvarchar(15),
    shipregion     nvarchar(15),
    shippostalcode nvarchar(10),
    shipcountry    nvarchar(15)
)
go

create table orderdetails
(
    orderid   int not null
        constraint fk_orderdetails_orders
            references orders,
    productid int not null
        constraint fk_orderdetails_products
            references products,
    unitprice money not null
        constraint ck_unitprice
            check ((unitprice >= 0)),
    quantity  int not null
        constraint ck_quantity
            check ((quantity > 0)),
    discount  real not null
        constraint ck_discount
            check ((discount >= 0 and discount <= 1)),
    constraint pk_order_details
        primary key (orderid, productid)
)
go


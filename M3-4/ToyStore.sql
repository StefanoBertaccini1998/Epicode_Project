/*Drop schema*/
drop schema toysCenter;

/*Create schema*/
create schema toysCenter;

/*Use schema*/
use toysCenter;

/*Create Category table*/
CREATE TABLE IF NOT EXISTS category (
  categoryId INT NOT NULL AUTO_INCREMENT,
  categoryName VARCHAR(45) UNIQUE NOT NULL,
  PRIMARY KEY (categoryId)
);

/*Create Product table*/
CREATE TABLE IF NOT EXISTS product (
  productId INT NOT NULL AUTO_INCREMENT,
  productName VARCHAR(45) UNIQUE NOT NULL,
  price DECIMAL(8,2) NOT NULL,
  producer VARCHAR(45),
  productCategory INT NOT NULL,
  PRIMARY KEY (productId),
  FOREIGN KEY (productCategory) REFERENCES category (categoryId) ON DELETE RESTRICT ON UPDATE CASCADE
);

/*Create Area table*/
CREATE TABLE IF NOT EXISTS area (
  areaId INT NOT NULL AUTO_INCREMENT,
  areaName VARCHAR(45) UNIQUE NOT NULL,
  PRIMARY KEY (areaId)
);

/*Create Region table*/
CREATE TABLE IF NOT EXISTS region (
  regionId INT NOT NULL AUTO_INCREMENT,
  regionName VARCHAR(45) UNIQUE NOT NULL,
  regionArea INT NOT NULL,
  PRIMARY KEY (regionId),
  FOREIGN KEY (regionArea) REFERENCES area (areaId) ON DELETE RESTRICT ON UPDATE CASCADE
);

/*Create Sales table*/
CREATE TABLE IF NOT EXISTS sales (
  salesId INT NOT NULL AUTO_INCREMENT,
  salesProductId INT NOT NULL,
  salesRegionId INT NOT NULL,
  salesDate DATE NOT NULL,
  quantity INT NOT NULL,
  PRIMARY KEY (salesId),
  FOREIGN KEY (salesProductId) REFERENCES product (productId),
  FOREIGN KEY (salesRegionId) REFERENCES region (regionId)
);

/*Insert into category table*/
Insert into category
 (categoryName)
Values
('Peluche'),('Veicoli'),('Giochi da spiaggia'),
('Giochi da sportivi'),('Puzzle');

/*Insert into area table*/
Insert into area
 (areaName)
Values
('WestEurope'),('SouthEurope'),('EastEurope'),
('NorthEurope');

/*Insert into product table*/
Insert into product
 (productCategory,productName,price,producer)
Values
('1','Orsetto Teo','30.90','Trudi'),
('2','Porsche 911 GT3','3.67','Hot Wheels'),
('3','8 bocce con valigetta','8.99',null),
('4','Canestro basket regolabile','24.99','Bakaji'),
('5','Puzzle Pokemon','13.49','Nintendo'),
('1','Tigre Lea','35.90','Trudi'),
('2','Nissan GTR 2011','4.32','Hot Wheels'),
('3','Pistola spara acqua','10.99','Nerf'),
('4','Super santos','2.99',null),
('5','Puzzle Principesse','23.99','Disney');

/*Insert into region table*/
Insert into region
 (regionArea,regionName)
Values
('1','France'),
('1','Germany'),
('2','Greece'),
('2','Italy'),
('3','Ukraine'),
('3','Belarus'),
('4','Sweden'),
('4','Norway');

/*Insert into sales table*/
Insert into sales
 (salesProductId, salesRegionId, salesDate, quantity)
Values
/*2017*/
('1','1','2017-01-06','100'),
('7','2','2017-01-04','50'),
('2','4','2017-01-03','1000'),
('8','1','2017-01-05','100'),
('3','2','2017-01-06','30'),
('4','1','2017-01-12','10'),
('5','1','2017-01-02','100'),
('6','4','2017-01-09','1000'),
/*2018*/
('5','1','2018-01-06','100'),
('7','2','2018-01-04','50'),
('9','4','2018-01-03','1000'),
('8','1','2018-01-05','100'),
('3','2','2018-01-06','30'),
('2','1','2018-01-12','10'),
('1','1','2018-01-02','100'),
('6','4','2018-01-09','1000'),
/*2019*/
('2','1','2019-01-06','100'),
('1','2','2019-01-04','50'),
('3','4','2019-01-03','1000'),
('8','1','2019-01-05','100'),
('6','2','2019-01-06','30'),
('9','1','2019-01-12','10'),
('7','1','2019-01-02','100'),
('4','4','2019-01-09','1000'),
/*2023*/
('7','1','2023-01-06','10'),
('8','2','2023-01-04','5'),
('2','4','2023-01-03','10'),
('3','1','2023-01-05','10'),
('2','2','2023-01-06','30'),
('4','4','2023-01-12','10'),
('6','1','2023-12-02','100');

/*Query (1) Distinct Primary key*/
select categoryId, count(categoryId) as quantity from category group by categoryId;
select areaId, count(areaId) as quantity from area group by areaId;
select productId, count(productId) as quantity from product group by productId;
select regionId, count(regionId) as quantity from region group by regionId;
select salesId, count(salesId) as quantity from sales group by salesId;

/*Query (2) Get the revenue in years for only product sold*/
select sls.salesProductId, prd.productName, SUM(sls.quantity)*prd.price as revenue, year(sls.salesDate) as yearSls
from sales sls join product prd on sls.salesproductId= prd.productId 
group by sls.salesproductId, yearSls
order by revenue desc;

/*Query (3) Get the revenue for region in years, order by year and revenue desc*/
with revenue_for_product as (
select sls.salesRegionId, SUM(sls.quantity)*prd.price as revenueProduct, year(sls.salesDate) as yearSls
from sales sls join product prd on sls.salesproductId = prd.productId
group by yearSls, sls.salesproductId, sls.salesRegionId)

select reg.regionName, SUM(rxp.revenueProduct) as revenueForYear, rxp.yearSls from revenue_for_product rxp 
join region reg on rxp.salesRegionId = reg.regionId
group by rxp.salesRegionId, rxp.yearSls
/*Mettendo solo un desc non ordinava per entrambe le grandezze*/
order by rxp.yearSls desc, revenueForYear desc;

/*Query (4) Get the category most requested*/
with categoryProductYear as (
select prd.productCategory, SUM(sls.quantity) as productOrdered, year(sls.salesDate) as yearSls
from sales sls join product prd on sls.salesproductId = prd.productId
group by yearSls, sls.salesproductId)

select cat.categoryName, SUM(cpy.productOrdered) as quantityRequestedInYear from categoryProductYear cpy
join category cat on cpy.productCategory = cat.categoryId
/*Per me sarebbe da aggiungere "Nell' anno precedente" perchè se avessimo dati del 1960 penso non avrebbe valore
 in comparazione con i dati odierni se non andando a tracciare un andamento annuale degli acquisti e quindi definire un trend
 Perciò per domanda ambigua aggiungo l'anno precedente ed evidenzio un dato secondo me più integro*/
where yearSls = '2023'
/*Fine aggiunta*/
group by productCategory
order by quantityRequestedInYear desc
/*Sarebbe da aggiungere
limit 1
Per avere solo la categoria prioritaria, essendo i dati inseriti da me reputo sarebbe come individuare un valore per un altro*/
;

/*Query (5) Get product not bought*/

/*(A)*/
select * from product prd 
where prd.productId NOT IN (
select salesProductId from sales);

/*(B)*/
select *
from product prd 
left join sales sls on prd.productId = sls.salesProductId
where sls.salesId is null;

/*Query (6) Get the last sales date for product*/
select prd.productId, prd.productName, MAX(sls.salesDate) as lastDate from product prd
join sales sls on prd.productId = sls.salesProductId
group by prd.productId
order by lastDate desc;

/*Query (BONUS) Get all sales with code, date, product, category, region, area and a bollean condition (now>date+180?true:false)*/
select sls.salesId as codice, sls.salesDate as data, prd.productName as prodotto, cat.categoryName as categoria, reg.regionName as stato, arz.areaName as 'area vendita',
case when DATEDIFF(now(),sls.salesDate)>180 then true else false end as isPast180Days  from sales sls
join product prd on sls.salesProductId = prd.productId
join category cat on prd.productCategory = cat.categoryId
join region reg on sls.salesRegionId = reg.regionId
join area arz on reg.regionArea = arz.areaId
order by data desc



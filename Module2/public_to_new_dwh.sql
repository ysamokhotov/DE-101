--create schema new_dwh

--customers

--creating table
drop table if exists new_dwh.customers;
CREATE TABLE new_dwh.customers
(
 user_id          serial NOT NULL,
 customer_id      varchar(50) NOT NULL,
 customer_name    varchar(128) NOT NULL,
 customer_segment varchar(50) NOT NULL
)

--deleting rows
truncate table new_dwh.customers

--generating data
insert into new_dwh.customers
select
	row_number () over (), customer_id, customer_name, segment customer_segment
from (select distinct customer_id, customer_name, segment from public.sample_superstore) t
	
--geo

--creating table
drop table if exists new_dwh.geo;
CREATE TABLE new_dwh.geo
(
 geo_id      serial NOT NULL,
 country     varchar(50) NOT NULL,
 city        varchar(50) NOT NULL,
 "state"       varchar(50) NOT NULL,
 postal_code varchar(50) NULL,
 region      varchar(50) NOT NULL
);

--deleting rows
truncate table new_dwh.geo;

--generating data
insert into new_dwh.geo
select
	row_number () over (), country , city , state , postal_code, region
from (select distinct country , city , state , postal_code, region from public.sample_superstore) t;

--fill data missing - update postal code for Burlington
update new_dwh.geo 
set postal_code = '05401' where postal_code is null;

--shipping

--creating table
drop table if exists new_dwh.shipping;
CREATE TABLE new_dwh.shipping
(
 ship_id   serial NOT NULL,
 ship_mode varchar(50) NOT NULL
);

--deleting rows
truncate table new_dwh.shipping;

--generating data
insert into new_dwh.shipping
select
	row_number () over (), ship_mode
from (select distinct ship_mode from public.sample_superstore) t;

--products

--creating table
drop table if exists new_dwh.products;
CREATE TABLE new_dwh.products
(
 product_number serial NOT NULL,
 product_id     varchar(50) NOT NULL,
 product_name   varchar(128) NOT NULL,
 category       varchar(50) NOT NULL,
 "sub_category"   varchar(50) NOT NULL,
 price          numeric NOT NULL
);

--deleting rows
truncate table new_dwh.products;

--generating data
insert into new_dwh.products
select row_number () over (), *
from
	(select
		distinct product_id, product_name, category, sub_category, round(price::numeric,2)
	from (select distinct product_id, product_name, category, sub_category, 
		sales / (1-discount) / quantity as price from public.sample_superstore) t) tt;
	
--orders

--creating table
drop table if exists new_dwh.orders;
CREATE TABLE new_dwh.orders
(
 order_number   serial NOT NULL,
 order_id       varchar(50) NOT NULL,
 order_date     date NOT NULL,
 product_number int NOT NULL,
 geo_id         int NOT NULL,
 ship_id        int NOT NULL,
 user_id        int NOT NULL,
 quantity       int NOT NULL,
 sales          numeric NOT NULL,
 profit         numeric NOT NULL,
 discount       numeric NOT null
);

--deleting rows
truncate table new_dwh.orders;

--generating data
insert into new_dwh.orders
select distinct order_number, order_id, order_date, product_number, geo_id, ship_id, user_id, quantity, sales, profit, discount
from
	(select
		distinct dense_rank () over(order by order_id) order_number, order_id, order_date, product_number, geo_id, ship_id, user_id, quantity, sales, profit, discount
	from(
		select distinct order_id, order_date, product_id, country, city, state, region, postal_code, ship_mode, customer_id, quantity, sales, profit, discount
		from sample_superstore) ss
	inner join new_dwh.products p on p.product_id = ss.product_id
	inner join new_dwh.geo g on ss.country = g.country and ss.city = g.city and ss.state = g.state and ss.region = g.region and ss.postal_code = cast(g.postal_code as integer)
	inner join new_dwh.shipping s on s.ship_mode = ss.ship_mode
	inner join new_dwh.customers c on c.customer_id = ss.customer_id) t;

--returns

--creating table
drop table if exists new_dwh.returned;
CREATE TABLE new_dwh.returned
(
 order_number int NOT NULL,
 returned     boolean NOT NULL
);

--deleting rows
truncate table new_dwh.returned;

--generating data
insert into new_dwh.returned
select distinct order_number, returned::boolean
from new_dwh.orders o
inner join public.returns r on r.order_id = o.order_id;
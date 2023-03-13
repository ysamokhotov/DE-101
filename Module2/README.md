# **Модуль 2**
## **Установка БД**
Установил локально базу PostgreSQL 15.
## **Загрузка даных в БД**
Данные загружены базу с помощью python (pandas)
## **SQL запросы**
1. Суммарные продажи по штатам, где общее количество заказов больше 10
```sql
select state,
	count(distinct order_id) orders_cnt,
	sum(sales) total_inc
from sample_superstore
group by state
having count(distinct order_id) > 10
order by total_inc desc
```
2. Какие товары самые возвращаемые и упущенная выгода по ним
```sql
select product_name,
	sum(quantity) q_returned,
	sum(sales) lost_income
from sample_superstore
where order_id in(
	select distinct order_id
	from returns)
group by product_name
order by 3 desc, 2 desc
```
3. Ранкинг сейлзов по продажам
```sql
select person salesman,
	count(distinct order_id) sold_orders,
	sum(sales) total_income,
	sum(profit) total_profit
from sample_superstore
left join people using(region)
group by person
order by 4 desc
```
## **Нарисовать модель данных в SQLdbm**
![Image alt](https://github.com/ysamokhotov/DE-101/blob/main/Module2/pics/db_model.JPG)

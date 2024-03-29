# **Модуль 2**
## **Установка БД**
Установил локально базу PostgreSQL 15.
## **Загрузка даных в БД**
<a href="https://github.com/ysamokhotov/DE-101/blob/main/Module2/data_upload_into_postgres_db.ipynb">Данные загружены в Postgres с помощью python (pandas)</a>.
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

В модели я выделил несколько отдельных сущностей: информация по клиентам, информация по шиппингу, гео, данные о продуктах, заказы и отдельно заказы с возвратом. <a href="https://github.com/ysamokhotov/DE-101/blob/main/Module2/public_to_new_dwh.sql">Скрипт модели</a>.
## **Создать базу данных в облаке**
Создал staging БД в Clickhouse, загружал локальные таблицы через импорт csv.

![Image alt](https://github.com/ysamokhotov/DE-101/blob/main/Module2/pics/clickhouse_db.JPG)

<a href="https://github.com/ysamokhotov/DE-101/blob/main/Module2/clickhouse_connection_and_queries.ipynb">Сделал несколько аналитических запросов к БД</a>.

## **Сделать дэшборд в BI**
Для создания дашборда использовал Power BI (поскольку он для меня наиболее привычен) подключался к Clickhouse базе данных через OBDC протокол. 

<a href="https://github.com/ysamokhotov/DE-101/blob/main/Module2/sample_superstore_dashboard.pbix">PBI файл дашборда</a>.

![Image alt](https://github.com/ysamokhotov/DE-101/blob/main/Module2/pics/pbi_dashboard.JPG)
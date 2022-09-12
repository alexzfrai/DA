--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task13 (lesson3)
--Компьютерная фирма: Вывести список всех продуктов и производителя с указанием типа продукта (pc, printer, laptop). Вывести: model, maker, type
select model,maker,type  from product p ;

--task14 (lesson3)
--Компьютерная фирма: При выводе всех значений из таблицы printer дополнительно вывести для тех, у кого цена вышей средней PC - "1", у остальных - "0"
select *, 
case 
	when price >(select AVG(price) from printer) 
	then 1 
	else 0 
	end flag 
from printer
;
--task15 (lesson3)
--Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL)
with ship_outcomes as (select ship as name,class from outcomes o
left join ships s
on o.ship=s.name)
(select name from ships where class is null)
union
(select name from ship_outcomes where class is null)
;


--task16 (lesson3)
--Корабли: Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду.
select name 
from battles b  
where extract(year from date) not in
(select launched from ships where launched is not null)
;

--task17 (lesson3)
--Корабли: Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.
select battle from outcomes o 
left join
ships s 
on
o.ship = s.name
where class = 'Kongo'
;

--task1  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_300) для всех товаров (pc, printer, laptop) с флагом, если стоимость больше > 300. Во view три колонки: model, price, flag
create view all_products_flag_300 as
select model, price,
case 
	when price >300 
	then 1 
	else 0 
	end flag 
from (select model,price from printer p 
union
select model,price from laptop 
union
select model,price from pc) as o
;;

select * from all_products_flag_300;




--task2  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_avg_price) для всех товаров (pc, printer, laptop) с флагом, если стоимость больше cредней . Во view три колонки: model, price, flag
create view all_products_flag_avg_price as
with model_price as (select model,price from printer p 
union
select model,price from laptop 
union
select model,price from pc)
select model, price,
case 
	when price > (select AVG(price) from model_price) 
	then 1 
	else 0 
	end flag 
from model_price
;;

select * from all_products_flag_avg_price;

--task3  (lesson4)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. Вывести model
with model_printer_price as (select maker,p.model,price from product p 
left join printer p2 
on p.model = p2.model
where p.type = 'Printer')
select model from model_printer_price
where maker = 'A' and price > (select avg(price) from model_printer_price where maker='D' or maker='C');



--task4 (lesson4)
-- Компьютерная фирма: Вывести все товары производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. Вывести model
with model_price as (select model,price from printer p 
union
select model,price from laptop 
union
select model,price from pc),
model_printer_price as (select maker,p.model,price from product p 
left join printer p2 
on p.model = p2.model
where p.type = 'Printer'),
model_makerA_price as (select maker,p.model,price from product p 
left join model_price m2 
on p.model = m2.model
where maker = 'A')
select model from model_makerA_price
where price > (select avg(price) from model_printer_price where maker='D' or maker='C');




--task5 (lesson4)
-- Компьютерная фирма: Какая средняя цена среди уникальных продуктов производителя = 'A' (printer & laptop & pc)
with model_price as (select model,price from printer p 
union
select model,price from laptop 
union
select model,price from pc),
model_makerA_price as (select maker,p.model,price from product p 
left join model_price m2 
on p.model = m2.model
where maker = 'A')
select AVG(price) from model_makerA_price;

 

--task6 (lesson4)
-- Компьютерная фирма: Сделать view с количеством товаров (название count_products_by_makers) по каждому производителю. Во view: maker, count
create view count_products_by_makers as
select maker,count(*) from product p
group by maker;;

select * from count_products_by_makers;

--task7 (lesson4)
-- По предыдущему view (count_products_by_makers) сделать график в colab (X: maker, y: count)
request = """
select * from count_products_by_makers 
"""
df = pd.read_sql_query(request, conn)
fig = px.bar(x=df.maker.to_list(), y=df['count'], labels={'x':'maker', 'y':'count'})
fig.show()

--task8 (lesson4)
-- Компьютерная фирма: Сделать копию таблицы printer (название printer_updated) и удалить из нее все принтеры производителя 'D'
create table printer_updated as 
select printer.code, printer.model, printer.color, printer.type,printer.price from printer
left join product p 
on printer.model=p.model
where maker != 'D';


--task9 (lesson4)
-- Компьютерная фирма: Сделать на базе таблицы (printer_updated) view с дополнительной колонкой производителя (название printer_updated_with_makers)
create view printer_updated_with_makers as
select printer_updated.code, printer_updated.model, printer_updated.color, printer_updated.type,printer_updated.price, p.maker from printer_updated
left join product p 
on printer_updated.model = p.model;;

select * from printer_updated_with_makers;

--task10 (lesson4)
-- Корабли: Сделать view c количеством потопленных кораблей и классом корабля (название sunk_ships_by_classes). Во view: count, class (если значения класса нет/IS NULL, то заменить на 0)
create view sunk_ships_by_classes as
select count(class),class 
from (select ship, coalesce(class,'0') as class
from(
select * from outcomes o 
left join ships
on o.ship = ships.name
where result = 'sunk') as su) as su2
group by class;;

select * from sunk_ships_by_classes;

--task11 (lesson4)
-- Корабли: По предыдущему view (sunk_ships_by_classes) сделать график в colab (X: class, Y: count)
request = """
select * from sunk_ships_by_classes 
"""
df = pd.read_sql_query(request, conn)
fig = px.bar(x=df['class'].to_list(), y=df['count'], labels={'x':'class', 'y':'count'})
fig.show()

--task12 (lesson4)
-- Корабли: Сделать копию таблицы classes (название classes_with_flag) и добавить в нее flag: если количество орудий больше или равно 9 - то 1, иначе 0
create table classes_with_flag as
select *,
case 
	when numguns >= 9 
	then 1 
	else 0 
	end flag 
from classes;

--task13 (lesson4)
-- Корабли: Сделать график в colab по таблице classes с количеством классов по странам (X: country, Y: count)
request = """
select country,count(country) from classes group by country;
"""
df = pd.read_sql_query(request, conn)
fig = px.bar(x=df['country'].to_list(), y=df['count'], labels={'x':'country', 'y':'count'})
fig.show()

--task14 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название начинается с буквы "O" или "M".
with ship_outcomes as (select ship as name,class from outcomes o
left join ships s
on o.ship=s.name)
select count(name) from(
(select name from ships)
union
(select name from ship_outcomes)) as shipss
where name like 'M%' or name like 'O%'
;
--task15 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название состоит из двух слов.
with ship_outcomes as (select ship as name,class from outcomes o
left join ships s
on o.ship=s.name)
select count(name) from(
(select name from ships)
union
(select name from ship_outcomes)) as shipss
where (name not like '% % %') and (name like '% %')
;


--task16 (lesson4)
-- Корабли: Построить график с количеством запущенных на воду кораблей и годом запуска (X: year, Y: count)
request = """
select launched as year, count(launched) from ships group by year;
"""
df = pd.read_sql_query(request, conn)
fig = px.bar(x=df['year'].to_list(), y=df['count'], labels={'x':'year', 'y':'count'})
fig.show()

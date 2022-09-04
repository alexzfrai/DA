--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing

--task1
--Корабли: Для каждого класса определите число кораблей этого класса, потопленных в сражениях. Вывести: класс и число потопленных кораблей.
select class, count(class) as sunk from outcomes o 
left join ships
on o.ship = ships.name
where (result = 'sunk') and class is not null
group by class
;


--task2
--Корабли: Для каждого класса определите год, когда был спущен на воду первый корабль этого класса. Если год спуска на воду головного корабля неизвестен, определите минимальный год спуска на воду кораблей этого класса. Вывести: класс, год.

with ship_date as (select class, min(launched)  from ships
group by class)
select classes.class, min
from classes
left join ship_date
on classes.class = ship_date.class
;



--task3
--Корабли: Для классов, имеющих потери в виде потопленных кораблей и не менее 3 кораблей в базе данных, вывести имя класса и число потопленных кораблей.
with ship_by_class as (select class, count(*)  from ships
group by class),
sunk_class as (select class, count(class) as sunk from outcomes o 
left join ships
on o.ship = ships.name
where (result = 'sunk') and class is not null
group by class)
select ship_by_class.class, sunk from ship_by_class
left join sunk_class
on ship_by_class.class = sunk_class.class
where (count >=3) and sunk is not null
;


--task4
--Корабли: Найдите названия кораблей, имеющих наибольшее число орудий среди всех кораблей такого же водоизмещения (учесть корабли из таблицы Outcomes).
with all_ships as (
select name, class from ships
union
select ship, ship from outcomes) 
select name 
from all_ships 
join classes
on all_ships.class = classes.class
where numguns >= all(
select numguns 
from classes c1 
where (c1.displacement = classes.displacement) and (c1.class in (select class from all_ships)))
;


--task5
--Компьютерная фирма: Найдите производителей принтеров, которые производят ПК с наименьшим объемом RAM и с самым быстрым процессором среди всех ПК, имеющих наименьший объем RAM. Вывести: Maker
with 
PC_maker as (select * from Product
join PC 
on Product.model = PC.model),
MIN_RAM as (select maker,speed,ram from PC_maker
where ram = (select min(ram) from PC_maker where PC_maker.maker in (select distinct maker from Product
where type='Printer')))
select maker from MIN_RAM
where speed = (select max(speed) from MIN_RAM)
;


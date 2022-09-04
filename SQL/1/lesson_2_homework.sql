--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

-- Задание 1: Вывести name, class по кораблям, выпущенным после 1920
--
select name, class 
from Ships
where  launched > 1920
;
-- Задание 2: Вывести name, class по кораблям, выпущенным после 1920, но не позднее 1942
--
select name, class
from Ships
where  (launched > 1920) and (launched < 1942)
;

-- Задание 3: Какое количество кораблей в каждом классе. Вывести количество и class
--
select count(*), class
from Ships 
group by class
;
-- Задание 4: Для классов кораблей, калибр орудий которых не менее 16, укажите класс и страну. (таблица classes)
--
select class, country  
from classes
where bore >= 16;

-- Задание 5: Укажите корабли, потопленные в сражениях в Северной Атлантике (таблица Outcomes, North Atlantic). Вывод: ship.
--
select ship
from outcomes
where result = 'sunk' and battle = 'North Atlantic'
;

-- Задание 6: Вывести название (ship) последнего потопленного корабля
--

select ship
from (select Ship,date
from outcomes
left join battles
on outcomes.battle = battles.name
where result = 'sunk') as s1
where date = (select max(date) from (select Ship,date
from outcomes
left join battles
on outcomes.battle = battles.name
where result = 'sunk') s2)
;


-- Задание 7: Вывести название корабля (ship) и класс (class) последнего потопленного корабля
--
select ship,class
from (select *
from outcomes
left join battles
on outcomes.battle = battles.name
where result = 'sunk') as s1
left join ships
on s1.ship = ships.name
where date = (select max(date) from (select Ship,date
from outcomes
left join battles
on outcomes.battle = battles.name
where result = 'sunk') s2)
;

-- Задание 8: Вывести все потопленные корабли, у которых калибр орудий не менее 16, и которые потоплены. Вывод: ship, class
--
select ship, s1.class
from (select ship,result,class
from outcomes
left join ships
on outcomes.ship = ships.name
) s1
left join classes c 
on s1.class = c.class
where bore >= 16 and result = 'sunk'
;

-- Задание 9: Вывести все классы кораблей, выпущенные США (таблица classes, country = 'USA'). Вывод: class
--
select class from classes c 
where country = 'USA';

-- Задание 10: Вывести все корабли, выпущенные США (таблица classes & ships, country = 'USA'). Вывод: name, class
select name, ships.class
from ships 
left join classes
on ships.class = classes.class
where  country = 'USA'
;
--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task1 (lesson5)
-- Компьютерная фирма: Сделать view (pages_all_products), в которой будет постраничная разбивка всех продуктов (не более двух продуктов на одной странице). Вывод: все данные из laptop, номер страницы, список всех страниц
create view pages_all_products as
select code,model,speed,ram,hd,price,screen,ROW_NUMBER() OVER(partition by page_num) AS pages,page_num
from 
(SELECT *, 
      CASE WHEN num % 2 = 0 THEN num/2 ELSE num/2 + 1 END AS page_num
FROM (
SELECT *, ROW_NUMBER() OVER(ORDER BY price DESC) AS num 
FROM Laptop) as tn) as tn;;

select * from pages_all_products;


sample:
1 1
2 1
1 2
2 2
1 3
2 3

--task2 (lesson5)
-- Компьютерная фирма: Сделать view (distribution_by_type), в рамках которого будет процентное соотношение всех товаров по типу устройства. Вывод: производитель, тип, процент (%)
create view distribution_by_type as
with count_maker_type as (SELECT maker, type, count(*) as num_prod
FROM product
group by type, maker)
select maker, a.type, sum(num_prod)/sum(a.num)*100 as procent 
from count_maker_type
inner join
(select sum(num_prod) as num, type from count_maker_type group by type)a 
on count_maker_type.type=a.type
group by maker,a.type;;

select * from distribution_by_type;


--task3 (lesson5)
-- Компьютерная фирма: Сделать на базе предыдущенр view график - круговую диаграмму. Пример https://plotly.com/python/histograms/
request = """
select * from distribution_by_type 
"""
df = pd.read_sql_query(request, conn)
PC = df.loc[df['type'] == 'PC']
Laptop = df.loc[df['type'] == 'Laptop']
Printer = df.loc[df['type'] == 'Printer']
plt.pie(PC['procent'],labels=PC['maker']) 
plt.title("PC")
# show plot 
plt.show()
plt.pie(Laptop['procent'],labels=Laptop['maker']) 
plt.title("Laptop")
# show plot 
plt.show()
plt.pie(Printer['procent'],labels=Printer['maker']) 
plt.title("Printer")
# show plot 
plt.show()

--task4 (lesson5)
-- Корабли: Сделать копию таблицы ships (ships_two_words), но название корабля должно состоять из двух слов
create table ships_two_words as
select * from ships
where (name not like '% % %') and (name like '% %') ;

select * from ships_two_words;

--task5 (lesson5)
-- Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL) и название начинается с буквы "S"
with ship_name as ((select name from ships)
union
(select ship as name from outcomes))
select sa.name,class from ship_name sa
left join ships
on sa.name=ships.name
where (sa.name like 'S%')and(class is null)
;


--task6 (lesson5)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'C' и три самых дорогих (через оконные функции). Вывести model
(select model from(select p2.model, ROW_NUMBER() OVER(partition BY maker) AS num from product p 
left join printer p2 
on p.model=p2.model
where p.type = 'Printer' and maker = 'A' and price >= (select CASE WHEN AVG(price) is not null THEN AVG(price) ELSE 0 END AS avg 
from product p
left join printer p2 
on p.model=p2.model
where p.type = 'Printer'and maker = 'C'))b)
union
(select model from(select p.model, p2.price, ROW_NUMBER() OVER(order BY price desc) num 
from product p 
left join printer p2 
on p.model=p2.model
where p.type = 'Printer')a 
where num<4);


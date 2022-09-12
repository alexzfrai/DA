--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task1  (lesson7)
-- sqlite3: Сделать тестовый проект с БД (sqlite3, project name: task1_7). В таблицу table1 записать 1000 строк с случайными значениями (3 колонки, тип int) от 0 до 1000.
-- Далее построить гистаграмму распределения этих трех колонко
import sqlite3
import pandas as pd
import numpy as np
conn = sqlite3.connect('task1_7.db')  
c = conn.cursor()
df = pd.DataFrame(np.random.randint(0,1000,size=(1000, 3)), columns=list('ABC'))
df.to_sql('table1',conn)
request = """
select * from table1 
"""
df2 = pd.read_sql_query(request, conn)
df2 = df2.set_index('index')
hA = df2.hist()

--task2  (lesson7)
-- oracle: https://leetcode.com/problems/duplicate-emails/

select email
from (select email, count(*) as c2 from Person group by email)
where c > 1

--task3  (lesson7)
-- oracle: https://leetcode.com/problems/employees-earning-more-than-their-managers/

with employees as (select *  from Employee where managerId is not null),
manager as (select *  from Employee where managerId is null)
select employees.name as Employee from employees
left join manager
on employees.managerId = manager.id
where employees.salary > manager.salary

--task4  (lesson7)
-- oracle: https://leetcode.com/problems/rank-scores/

select score, dense_rank() OVER(ORDER BY score DESC) as rank from Scores

--task5  (lesson7)
-- oracle: https://leetcode.com/problems/combine-two-tables/

select Person.firstName, Person.lastName, Address.city, Address.state
from Person
left join Address
on Person.personId=Address.personId
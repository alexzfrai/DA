--task1  (lesson8)
-- oracle: https://leetcode.com/problems/department-top-three-salaries/

select Department,Employee,Salary
from (select Department.name as Department, Employee.name as Employee, Employee.salary as Salary, DENSE_RANK() OVER (partition by Department.name order by Employee.salary Desc) AS Ra
from Employee
join Department
on Employee.departmentId = Department.id)
where Ra <=3

--task2  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/17

select fm.member_name, fm.status, aaa.costs 
from FamilyMembers as fm
join (select p.family_member,sum(p.unit_price*p.amount) as costs 
from Payments as p
where extract(year from p.date) = 2005 
GROUP by p.family_member ) as aaa
on fm.member_id = aaa.family_member;

--task3  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/13

select name from (select name, COUNT(*) as c
from passenger
GROUP by name) as pas
WHERE c>=2

--task4  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/38

select count from (select first_name , COUNT(*) as count
from student
GROUP by first_name) as stud
WHERE first_name ='anna';

--task5  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/35

select COUNT(DISTINCT classroom) as count  from Schedule
where extract(year from date) = 2019 and extract(MONTH from date) = 09 and extract(DAY from date) = 02

--task6  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/38

select count from (select first_name , COUNT(*) as count
from student
GROUP by first_name) as stud
WHERE first_name ='anna';

--task7  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/32

SELECT floor(AVG(2022 - extract(YEAR from birthday))) as age
from FamilyMembers

--task8  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/27

select good_type_name, costs
from (select sum(costs) as costs,type from (select p.good,sum(p.unit_price*p.amount) as costs 
from Payments as p
where extract(year from p.date) = 2005 
GROUP by p.good) as a1
join goods as g
on a1.good=g.good_id 
GROUP by type) as g2 join GoodTypes
on g2.type=GoodTypes.good_type_id ;

--task9  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/37

SELECT min(TIMESTAMPDIFF(YEAR,birthday,CURrent_DATE))as year
from Student

--task10  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/44

select max(TIMESTAMPDIFF(YEAR,birthday,CURrent_DATE))as max_year
from student 
join (select s.student, c.name
from Student_in_class as s
join class  as c
on s.class=c.id 
where c.name like '10%') as sc 
on student.id=sc.student 


--task11 (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/20

select fm.status, fm.member_name, sum(p.unit_price*p.amount) as costs
FROM FamilyMembers as fm 
join Payments as p 
on fm.member_id= p.family_member
join goods as g
on p.good=g.good_id 
join GoodTypes as gt 
on g.type=gt.good_type_id 
where good_type_name ='entertainment'
GROUP by fm.status, fm.member_name

--task12  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/55

with cl1 as (select name,COUNT(*) as c1 from Trip
join Company
on Trip.company = Company.id
GROUP by name)
DELETE from Company
where name in (select name from cl1 where c1 = (select min(c1) from cl1))

--task13  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/45

with cl1 as (select *, DENSE_RANK() OVER (order by c DESC ) AS Ra
from (select classroom ,COUNT(*) as c FROM Schedule GROUP by classroom) as cl)
select classroom from cl1 
where Ra = (select min(RA) from Cl1)

--task14  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/43

select last_name from Teacher
where id in (select teacher from Schedule
join Subject
on Schedule.subject= subject.id
where name='Physical Culture')
ORDER by last_name

--task15  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/63

Select CONCAT(last_name,'.',LEFT(first_name , 1),'.',LEFT(middle_name, 1),'.') as name 
from Student
ORDER by last_name,first_name 

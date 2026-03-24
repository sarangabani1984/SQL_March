
select * from emp

with CTE AS (
    select 
    e.emp_id, 
    e.emp_name, 
    m.emp_name as manager_name,
    e.salary as employee_salary,
    m.salary as manager_salary
    from emp e join emp m on  e.manager_id =m.emp_id
)
select 
emp_id, emp_name, manager_name, employee_salary, manager_salary
from CTE
where employee_salary > manager_salary


CREATE TABLE emp2 (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    manager_id INT,
    salary INT,
    hire_date DATE,
    FOREIGN KEY (manager_id) REFERENCES emp2(emp_id)
);

INSERT INTO emp2 VALUES
(1, 'Alice', 'Management', NULL, 80000, '2015-01-10'),
(2, 'Bob', 'Sales', 1, 50000, '2018-03-15'),
(3, 'Charlie', 'Sales', 1, 55000, '2019-05-20'),
(4, 'David', 'IT', 2, 45000, '2020-07-22'),
(5, 'Eve', 'IT', 2, 48000, '2020-08-11'),
(6, 'Frank', 'HR', 1, 52000, '2017-11-05'),
(7, 'Grace', 'HR', 6, 42000, '2021-02-14'),
(8, 'Henry', 'Sales', 3, 40000, '2022-01-08');


SELECT e.emp_id,
    e.emp_name,
    m.emp_name
from emp2 as e 
left join emp2 as m 
on   e.manager_id = m.emp_id
ORDER BY e.emp_id;

SELECT 
    e.emp_id,
    e.emp_name AS employee_name,
    m.emp_name AS manager_name
FROM emp2 e
LEFT JOIN emp2 m ON  m.emp_id = e.manager_id
ORDER BY e.emp_id;

SELECT * from emp2
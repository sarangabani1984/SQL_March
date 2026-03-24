
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
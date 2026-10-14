USE CompanyDB; 
-- inner join
SELECT  
e.emp_id,  
e.emp_name,  
e.salary,  
d.dept_name  
FROM Employee e  
INNER JOIN Department d  
ON e.dept_id = d.dept_id  
ORDER BY e.emp_id;  


-- left join
SELECT  
d.dept_id,  
d.dept_name,  
e.emp_name,  
e.salary FROM Department d  
LEFT JOIN Employee e  
ON d.dept_id = e.dept_id  
ORDER BY d.dept_id, e.emp_id; 


-- self join
SELECT 
e1.emp_name AS employee_1, 
e2.emp_name AS employee_2, 
e1.dept_id, 
e1.salary AS salary_1, 
e2.salary AS salary_2 
FROM Employee e1 
INNER JOIN Employee e2 
ON e1.dept_id = e2.dept_id 
AND e1.emp_id < e2.emp_id 
ORDER BY 
e1.dept_id, 
e1.emp_id, 
e2.emp_id 
LIMIT 10; 

-- way join
SELECT  
e.emp_name,  
d.dept_name,  
p.project_name,  
e.salary  
FROM Employee e  
INNER JOIN Department d  
ON e.dept_id = d.dept_id  
INNER JOIN Project p  
ON e.project_id = p.project_id  
ORDER BY d.dept_name, e.emp_name; 

-- correlated subquery
SELECT  
e.emp_id,  
e.emp_name,  
e.salary,  
e.dept_id FROM Employee e  
WHERE e.salary > (  
SELECT AVG(e2.salary)  
FROM Employee e2  
WHERE e2.dept_id = e.dept_id  
)  
ORDER BY e.dept_id, e.salary DESC; 

-- exists
SELECT  
d.dept_id,  
FROM Department d  
WHERE EXISTS (  
SELECT 1  
FROM Employee e  
WHERE e.dept_id = d.dept_id  
AND e.salary > 80000  
)  
ORDER BY d.dept_id;  

--simulated intersect
FROM Employee  
WHERE emp_id IN (  
SELECT emp_id  
FROM Employee  
WHERE dept_id = 1  
)  
AND emp_id IN (  
SELECT emp_id  
FROM Employee  
WHERE salary > 70000  
)  
ORDER BY emp_id; 

-- simulated except
SELECT emp_id, emp_name, salary  
FROM Employee  
WHERE emp_id IN (  
SELECT emp_id  
FROM Employee  
WHERE salary > 70000  
)  
AND emp_id NOT IN (  
SELECT emp_id 
FROM Employee  
WHERE dept_id = 1  
)  
ORDER BY emp_id; 

-- explain - execution plan
-- a. explain for inner join
EXPLAIN  
SELECT  
e.emp_name,  
d.dept_name FROM Employee e  
INNER JOIN Department d  
ON e.dept_id = d.dept_id  
WHERE e.salary > 70000;  

-- b. explain for correlated subquery
EXPLAIN  
SELECT  
e.emp_name,  
e.salary FROM Employee e  
WHERE e.salary > (  
SELECT AVG(e2.salary)  
FROM Employee e2  
WHERE e2.dept_id = e.dept_id  
); 

-- c. explain for exists
EXPLAIN  
SELECT d.dept_name  
FROM Department d  
WHERE EXISTS (  
SELECT 1  
FROM Employee e  
WHERE e.dept_id = d.dept_id  
AND e.salary > 80000  
);  

 

 
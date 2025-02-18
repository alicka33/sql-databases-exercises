SELECT * FROM employees 
WHERE  date_employed > ALL(
SELECT date_end FROM projects
);

SELECT * FROM employees
WHERE salary >= ANY(
SELECT 4*salary FROM employees
);

SELECT department_id, MAX(salary) FROM employees
WHERE department_id IN 
(
SELECT d.department_id FROM departments d INNER JOIN addresses a USING(address_id) 
JOIN countries c USING(country_id)
WHERE c.name = 'Polska'
)
GROUP BY department_id;

--skorelowane

SELECT * FROM employees e1
WHERE e1.salary > 
(
    SELECT AVG(e2.salary) FROM employees e2 
    WHERE e1.department_id = e2.department_id
);


-- ???
SELECT region_id FROM regions r INNER JOIN reg_countries c USING(region_id)
WHERE c.country_id IS NULL;

SELECT * FROM employees e1
WHERE e1.employee_id NOT IN
(
    SELECT  e2.manager_id FROM employees e2 
    WHERE e1.employee_id = e2.manager_id
);

SELECT * FROM employees e1
WHERE salary >
(
SELECT AVG(e2.salary) FROM employees e2
WHERE e1.position_id = e2.position_id
GROUP BY e2.position_id);


SELECT * FROM employees e1
WHERE e1.employee_id IN
(
SELECT e2.manager_id FROM employees e2
WHERE e1.employee_id = e2.manager_id
) AND e1.salary >
(
SELECT AVG(e3.salary) FROM employees e3
);

SELECT * FROM employees e1
WHERE e1.employee_id IN
(
SELECT e2.manager_id FROM employees e2
WHERE e1.employee_id = e2.manager_id
) 
AND e1.salary >
(
SELECT AVG(e3.salary) FROM employees e3
WHERE e3.position_id = e1.position_id
);

-- od ch³opaków 
SELECT SUBSTR(name, 0, 1) as firstLetter, AVG(salary) FROM employees
GROUP BY SUBSTR(name, 0, 1)
HAVING AVG(salary) IS NOT NULL;

SELECT d1.department_id, d1.name, d1.year_budget FROM departments d1
WHERE d1.year_budget < 
(
SELECT MAX(d2.year_budget) FROM departments d2
)
ORDER BY d1.year_budget DESC
FETCH FIRST 1 ROW ONLY;

SELECT e1.name, e1.surname, d.name, 'Irene', 'Janowski'
FROM employees e1 INNER JOIN departments d USING(department_id)
WHERE e1.manager_id = 
(
SELECT e2.employee_id FROM employees e2
WHERE e2.name = 'Irene' AND e2.surname = 'Janowski'
);

-- ?????
SELECT gender, COUNT(employee_id) FROM employees
WHERE manager_id IS NULL
GROUP BY gender
UNION
SELECT gender, AVG(salary) FROM employees
WHERE manager_id IS NULL
GROUP BY gender;

SELECT e1.position_id, AVG(e1.salary) FROM employees e1
WHERE e1.employee_id IN 
(
    SELECT e2.manager_id FROM employees e2
)
GROUP BY e1.position_id;

-- jak tu wyswietliæ jeszcze puierwszego pracownika w zak³adzie???
SELECT e.name, e.surname, d.name, e2.name, e2.surname, e2.date_employed
FROM employees e INNER JOIN departments d USING(department_id) 
LEFT JOIN employees e2 ON e.manager_id = e2.employee_id
WHERE e.manager_id IS NOT NULL AND e.manager_id IN
(
    SELECT employee_id FROM employees
    WHERE date_employed =
    (
        SELECT MIN(date_employed) FROM employees
        WHERE department_id = e2.department_id 
    )
);

SELECT d.name FROM departments d INNER JOIN employees e USING(department_id)
WHERE e.employee_id IN
(
    SELECT employee_id FROM employees
    WHERE salary = 
    (
        SELECT MIN(salary) FROM employees
    )
);

SELECT 'K' as category, c.name, COUNT(d.department_id) 
FROM countries c INNER JOIN addresses a USING(country_id)
JOIN departments d USING(address_id)
WHERE EXTRACT(YEAR FROM d.established) BETWEEN 2006 AND 2010
GROUP BY c.name
UNION
SELECT 'R' as category, r.name, COUNT(d.department_id) 
FROM countries c INNER JOIN addresses a USING(country_id)
JOIN departments d USING(address_id) JOIN reg_countries rc USING(country_id)
JOIN regions r USING(region_id)
WHERE EXTRACT(YEAR FROM d.established) BETWEEN 2006 AND 2010
GROUP BY r.name;

SELECT name, surname FROM employees
WHERE gender = 'K' AND date_employed =
(
    SELECT MIN(date_employed) FROM employees
    WHERE gender = 'K'
);


SELECT e1.name, e1.surname, coalesce(e2.name, 'BRAK'), coalesce(e2.surname, 'BRAK') 
FROM employees e1 LEFT JOIN employees e2 ON (e1.manager_id = e2.employee_id)
WHERE e1.gender = 'M';

SELECT department_id, name, year_budget FROM departments 
WHERE year_budget < 
(
    SELECT MAX(year_budget) FROM departments
)
ORDER BY year_budget DESC 
FETCH FIRST 1 ROW WITH TIES;

SELECT SUBSTR(name, 0, 1), AVG(salary) FROM employees
GROUP BY SUBSTR(name, 0, 1)
HAVING AVG(salary) IS NOT NULL;

SELECT e1.position_id, AVG(e1.salary) FROM employees e1
WHERE e1.employee_id IN
(
    SELECT e2.manager_id FROM employees e2
)
GROUP BY e1.position_id;

SELECT gender, COUNT(employee_id), AVG(salary) FROM employees
WHERE manager_id IS NULL
GROUP BY gender;



SELECT * FROM employees e1
WHERE EXISTS
(
    SELECT e2.employee_id
    FROM employees e2
    WHERE e1.employee_id = e2.employee_id
);

SELECT e1.employee_id, e1.name, e1.surname FROM employees e1
WHERE e1.salary > 
(
    SELECT AVG(e2.salary) FROM employees e2
    WHERE e1.position_id = e2.position_id
);

SELECT r.region_id, name FROM regions r
WHERE NOT EXISTS
(
    SELECT reg.region_id FROM reg_countries reg
    WHERE r.region_id = reg.region_id
);

SELECT c.country_id, c.name FROM countries c
WHERE NOT EXISTS 
(
    SELECT reg.country_id FROM reg_countries reg
    WHERE c.country_id = reg.country_id
);

SELECT p.position_id FROM positions p
WHERE NOT EXISTS
(
    SELECT e.position_id FROM employees e
    WHERE p.position_id = e.position_id
);

SELECT position_id, AVG(salary) FROM employees
WHERE EXTRACT(MONTH FROM date_employed) BETWEEN 1 AND 6
GROUP BY position_id;

SELECT position_id, date_employed, EXTRACT(MONTH FROM date_employed) as month
FROM employees
WHERE EXTRACT(MONTH FROM date_employed) BETWEEN 1 AND 6;

SELECT e.name, e.surname, d.name, e2.name, e2.surname, e2.date_employed, MIN(e.date_employed)
FROM employees e JOIN departments d USING(department_id)
JOIN employees e2 ON e.manager_id = e2.employee_id
WHERE e2.date_employed = 
(
    SELECT MIN(e3.date_employed) FROM employees e3
    WHERE e2.department_id = e3.department_id
)
GROUP BY e.name, e.surname, d.name, e2.name, e2.surname, e2.date_employed
ORDER BY e.surname ASC;

SELECT e1.name, e1.surname, e1.salary FROM employees e1
WHERE e1.salary >= ALL
(
    SELECT e2.salary FROM employees e2
    WHERE e2.position_id = e1.position_id
    AND e2.department_id IN (101, 102, 103, 104)
);

SELECT e.name, e.surname, d.name, e2.name, e2.surname, d2.name 
FROM employees e INNER JOIN departments d USING(department_id)
INNER JOIN employees e2 ON (e.manager_id = e2.employee_id)
INNER JOIN departments d2 ON(e2.department_id = d2.department_id);


SELECT e.name, e.surname, d.name, e2.name, e2.surname, d2.name 
FROM employees e JOIN departments d USING(department_id)
JOIN employees e2 ON (e.manager_id = e2.employee_id)
JOIN departments d2 ON(e2.department_id = d2.department_id);

SELECT c.name, SUBSTR(a.city, 0, 1), COUNT(a.address_id) 
FROM countries c INNER JOIN addresses a USING(country_id)
GROUP BY c.name, SUBSTR(a.city, 0, 1);

SELECT e1.department_id, AVG(e1.salary) FROM employees e1
GROUP BY e1.department_id
HAVING AVG(e1.salary) >
(
    SELECT MAX(e2.salary) FROM employees e2
    WHERE e2.name LIKE 'P%' 
);

SELECT e.name, e.surname, d.name, e2.name, e2.surname FROM employees e 
INNER JOIN departments d USING(department_id)
INNER JOIN employees e2 ON(e.manager_id = e2.employee_id)
WHERE d.name IN ('Marketing', 'Kadry') AND e2.gender = 'M';

SELECT name FROM positions
WHERE position_id =
(
    SELECT position_id FROM employees
    WHERE salary = 
    (
        SELECT MAX(salary) FROM employees
    )
);

SELECT SUBSTR(min_salary,0, 1), AVG(max_salary) FROM positions
GROUP BY SUBSTR(min_salary,0, 1);


SELECT e.name, e.surname, e.salary FROM employees e 
WHERE e.employee_id IN
(
    SELECT e2.manager_id FROM employees e2
)
OR e.employee_id IN
(
    SELECT d.manager_id FROM departments d
);

SELECT e.name, e.surname, e.salary FROM employees e 
WHERE EXISTS
(
    SELECT e2.employee_id FROM employees e2
    WHERE e2.manager_id = e.employee_id
)
OR e.employee_id IN
(
    SELECT d.department_id FROM departments d
    WHERE d.manager_id = e.employee_id
);

SELECT d.name, p.name, MEDIAN(e.salary) FROM employees e
INNER JOIN departments d USING(department_id)
INNER JOIN positions p USING(position_id)
GROUP BY d.name, p.name
ORDER BY d.name, p.name ASC;

SELECT DISTINCT c.name
FROM countries c INNER JOIN addresses a USING (country_id)
INNER JOIN departments d USING(address_id)
INNER JOIN employees e USING(department_id)
WHERE EXTRACT(YEAR FROM e.birth_date) BETWEEN 1980 AND 2000;





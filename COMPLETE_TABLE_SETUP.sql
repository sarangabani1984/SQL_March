-- ========================================================
-- COMPLETE SQL TABLE SETUP FOR ALL INTERVIEW QUESTIONS
-- Database: Interview Practice
-- ========================================================

-- ========================================================
-- TABLE 1: emp2 (Organization Hierarchy - Self Join)
-- Use Cases: Q4, Q5, Q6 (Day 2 - Self Joins)
-- ========================================================
DROP TABLE IF EXISTS emp2;
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

-- ========================================================
-- TABLE 2: employees (Duplicate Detection)
-- Use Cases: Q1 (Finding Duplicates), Q2 (Deleting Duplicates)
-- ========================================================
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    email VARCHAR(50),
    salary INT
);

INSERT INTO employees VALUES
(1, 'Alice', 'alice@company.com', 80000),
(2, 'Bob', 'bob@company.com', 50000),
(3, 'Bob', 'bob@company.com', 50000),           -- DUPLICATE
(4, 'Charlie', 'charlie@company.com', 60000),
(5, 'Charlie', 'charlie@company.com', 60000),  -- DUPLICATE
(6, 'David', 'david@company.com', 45000),
(6, 'David', 'david@company.com', 45000);      -- DUPLICATE

-- ========================================================
-- TABLE 3: EMP1 & EMP2 (Set Operations - UNION)
-- Use Cases: Q3 (UNION vs UNION ALL)
-- ========================================================
DROP TABLE IF EXISTS EMP1;
CREATE TABLE EMP1 (
    emp_id INT,
    emp_name VARCHAR(50),
    salary INT
);

INSERT INTO EMP1 VALUES
(1, 'Alice', 80000),
(2, 'Bob', 50000),
(3, 'Charlie', 60000);

DROP TABLE IF EXISTS EMP2_UNION;
CREATE TABLE EMP2_UNION (
    emp_id INT,
    emp_name VARCHAR(50),
    salary INT
);

INSERT INTO EMP2_UNION VALUES
(2, 'Bob', 50000),           -- SAME as EMP1
(3, 'Charlie', 60000),       -- SAME as EMP1
(4, 'David', 45000);         -- NEW

-- ========================================================
-- TABLE 4: EMP & DEPT (Orphan Records - Foreign Keys)
-- Use Cases: Q4 (Missing Relationships/Orphan Records)
-- ========================================================
DROP TABLE IF EXISTS DEPT;
CREATE TABLE DEPT (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

INSERT INTO DEPT VALUES
(1, 'Sales'),
(2, 'IT'),
(3, 'HR');
-- NOTE: dept_id 4, 5 do NOT exist

DROP TABLE IF EXISTS EMP_ORPHAN;
CREATE TABLE EMP_ORPHAN (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT
);

INSERT INTO EMP_ORPHAN VALUES
(1, 'Alice', 1),      -- Valid: dept_id 1 exists
(2, 'Bob', 2),        -- Valid: dept_id 2 exists
(3, 'Charlie', 4),    -- ORPHAN: dept_id 4 does NOT exist
(4, 'David', 5),      -- ORPHAN: dept_id 5 does NOT exist
(5, 'Eve', 2);        -- Valid: dept_id 2 exists

-- ========================================================
-- TABLE 5: Salary_Tracking (Ranking - Top N)
-- Use Cases: Q5 (Second Highest Salary per Department)
-- ========================================================
DROP TABLE IF EXISTS Salary_Tracking;
CREATE TABLE Salary_Tracking (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary INT
);

INSERT INTO Salary_Tracking VALUES
-- Sales Department
(1, 'Alice', 'Sales', 80000),
(2, 'Bob', 'Sales', 70000),
(3, 'Charlie', 'Sales', 60000),
(4, 'David', 'Sales', 50000),
-- IT Department
(5, 'Eve', 'IT', 75000),
(6, 'Frank', 'IT', 65000),
(7, 'Grace', 'IT', 55000),
-- HR Department
(8, 'Henry', 'HR', 72000),
(9, 'Ivy', 'HR', 62000),
(10, 'Jack', 'HR', 52000);

-- ========================================================
-- TABLE 6: transactions (Case-Sensitive Filtering)
-- Use Cases: Q6 (Case-Sensitive Text Filtering)
-- ========================================================
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    user_name VARCHAR(50),
    amount DECIMAL(10, 2),
    transaction_date DATE
);

INSERT INTO transactions VALUES
(1, 'Shilpa', 1000.00, '2024-01-15'),
(2, 'shilpa', 500.00, '2024-01-16'),     -- Different case
(3, 'SHILPA', 1500.00, '2024-01-17'),   -- Different case
(4, 'Amit', 2000.00, '2024-01-18'),
(5, 'Shilpa', 750.00, '2024-01-19');

-- ========================================================
-- TABLE 7: gender_data (Conditional Updates)
-- Use Cases: Q7 (Gender Swap with CASE)
-- ========================================================
DROP TABLE IF EXISTS gender_data;
CREATE TABLE gender_data (
    person_id INT PRIMARY KEY,
    person_name VARCHAR(50),
    gender VARCHAR(10)
);

INSERT INTO gender_data VALUES
(1, 'Alice', 'Female'),
(2, 'Bob', 'Male'),
(3, 'Charlie', 'Male'),
(4, 'Diana', 'Female'),
(5, 'Edward', 'Male'),
(6, 'Fiona', 'Female');

-- ========================================================
-- VERIFICATION: Show all tables
-- ========================================================
PRINT '=== TABLE VERIFICATION ==='
PRINT 'emp2 table:'
SELECT * FROM emp2;

PRINT 'employees table:'
SELECT * FROM employees;

PRINT 'EMP1 table:'
SELECT * FROM EMP1;

PRINT 'EMP2_UNION table:'
SELECT * FROM EMP2_UNION;

PRINT 'DEPT table:'
SELECT * FROM DEPT;

PRINT 'EMP_ORPHAN table:'
SELECT * FROM EMP_ORPHAN;

PRINT 'Salary_Tracking table:'
SELECT * FROM Salary_Tracking;

PRINT 'transactions table:'
SELECT * FROM transactions;

PRINT 'gender_data table:'
SELECT * FROM gender_data;

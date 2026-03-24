SELECT 
    d.DepartmentID,
    d.DepartmentName,
    MAX(e.Salary) AS HighestSalary
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName
ORDER BY d.DepartmentID;



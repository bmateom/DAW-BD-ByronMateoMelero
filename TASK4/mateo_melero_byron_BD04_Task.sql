/*1. What is the purchase price, quantity in stock, and product name of the product with
the highest purchase price?*/

SELECT 
    buyPrice, quantityInStock, productName
FROM
    products
WHERE
    buyPrice = (SELECT 
            MAX(buyPrice)
        FROM
            products);
        
/*2. Show customers living on a Lane (with an address containing 'Lane' or 'Ln.') and
whose credit limit is greater than 80,000.*/

SELECT 
    customerNumber, addressLine1, addressLine2, creditLimit
FROM
    customers
WHERE
    (addressLine1 LIKE '%Lane%'
        OR addressLine1 LIKE '%Ln.%')
        AND creditLimit > 80000;
        
        
/*3. Show products (name and code) along with the number of orders they are included
in, only if the product is in more than 50 orders. Then, display products in descending
order by the number of orders.*/

SELECT 
    p.productCode,
    p.productName,
    COUNT(od.orderNumber) AS totalOrders
FROM
    products p
        JOIN
    orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName
HAVING COUNT(od.orderNumber) > 50
ORDER BY totalOrders DESC;


 /*4. Find the customer name, customer number, and payment amount for those payments
made in 2005 with an amount greater than 100,000.*/

SELECT 
    c.customerName,
    c.customerNumber,
    pay.amount,
    pay.paymentDate
FROM
    customers c
        JOIN
    payments pay ON c.customerNumber = pay.customerNumber
WHERE
    pay.paymentDate >= '2005-01-01'
        AND pay.paymentDate <= '2005-12-31'
        AND pay.amount > 100000;


/*5. Find the customer name and payment date of customers managed by employees who made
payments assigned to the San Francisco office. Sort results by payment date*/

SELECT 
    c.customerName, pay.paymentDate
FROM
    payments pay
        JOIN
    customers c ON c.customerNumber = pay.customerNumber
        JOIN
    employees emp ON c.salesRepEmployeeNumber = emp.employeeNumber
        JOIN
    offices ON offices.officeCode = emp.officeCode
WHERE
    offices.city = 'San Francisco'
ORDER BY pay.paymentDate DESC;


/*6. Find the name and customer number for those who made payments one day before
or after 2004-11-16.*/

SELECT DISTINCT
    c.customerName, c.customerNumber
FROM
    payments pay
        JOIN
    customers c ON c.customerNumber = pay.customerNumber
WHERE
    pay.paymentDate = '2004-11-15'
        OR pay.paymentDate = '2004-11-17';


/*7. Find all products (all fields) where the product line description contains the word
"Vintage" and the product description contains the word "tires."*/

SELECT 
    p.*
FROM
    products p
        JOIN
    productlines pl ON p.productLine = pl.productLine
WHERE
    pl.textDescription LIKE '%Vintage%'
        AND p.productDescription LIKE '%tires%';


/*8. Show the office name (with alias department) and the employee's name for those
employees who has not any customers assigned and whose office is in Japan.*/

SELECT 
    offices.city AS department, emp.firstName
FROM
    employees emp
        LEFT JOIN
    customers c ON emp.employeeNumber = c.salesRepEmployeeNumber
        JOIN
    offices ON offices.officeCode = emp.officeCode
WHERE
    c.customerNumber IS NULL
        AND offices.country = 'Japan';


/*9. Find all data of employees belonging to office with code 6 whose customers have not
made any payment.*/

SELECT 
    emp.*
FROM
    employees emp
WHERE
    emp.officeCode = 6
        AND emp.employeeNumber NOT IN (SELECT 
            c.salesRepEmployeeNumber
        FROM
            customers c
                JOIN
            payments pay ON c.customerNumber = pay.customerNumber);


/*10. Show the name of the office (as department) and the number of employees in each
office, ordering results from highest to lowest number of employees.*/

SELECT 
    offices.city AS department, COUNT(*) AS employees
FROM
    offices
        JOIN
    employees emp ON offices.officeCode = emp.officeCode
GROUP BY offices.city , offices.officeCode
ORDER BY employees DESC;

    
/*11. Show the number of orders placed each month of the year, ordered from January to
December.*/

SELECT 
    MONTH(o.orderDate) AS Month, COUNT(*) AS numberOfOrders
FROM
    orders o
GROUP BY Month
ORDER BY Month ASC;


/*12. Find the employee number, first name, and last name of employees managing
customers with payments exceeding 100,000 euros, ordering employees by
employeeNumber.*/

SELECT DISTINCT
    emp.employeeNumber, emp.firstName, emp.lastName
FROM
    employees emp
        JOIN
    customers c ON emp.employeeNumber = c.salesRepEmployeeNumber
        JOIN
    payments pay ON c.customerNumber = pay.customerNumber
WHERE
    pay.amount > 100000
ORDER BY employeeNumber ASC;


/*13. Show employees from the USA who do not have assigned customers.*/

SELECT 
    emp.*
FROM
    employees emp
        JOIN
    offices o ON emp.officeCode = o.officeCode
WHERE
    o.country = 'USA'
        AND emp.employeeNumber NOT IN (SELECT 
            c.salesRepEmployeeNumber
        FROM
            customers c
        WHERE
            c.salesRepEmployeeNumber IS NOT NULL);


/*14. How many years have passed since the older orders was placed? Show the order
number, customer number, and the years passed as antiquity.*/

SELECT 
    o.orderNumber,
    o.customerNumber,
    TIMESTAMPDIFF(YEAR,
        o.orderDate,
        CURDATE()) AS antiquity
FROM
    orders o
WHERE
    o.orderDate = (SELECT 
            MIN(orderDate)
        FROM
            orders);


/*15. Show the total number of payments, the minimum amount, and the maximum
amount among all payments.*/

SELECT 
    COUNT(*) AS NumberOfPayments,
    MIN(amount) AS MinimumAmount,
    MAX(amount) AS MaximumAmount
FROM
    payments;


/*16. Find the employee ID, first name, and number of customers managed by each
employee, only for employees with assigned customers that made payments below
3,000 euros.*/

SELECT 
    emp.employeeNumber, emp.firstName, COUNT(c.customerNumber)
FROM
    employees emp
        JOIN
    customers c ON emp.employeeNumber = c.salesRepEmployeeNumber
        JOIN
    payments pay ON c.customerNumber = pay.customerNumber
WHERE
    pay.amount < 3000
GROUP BY emp.employeeNumber, emp.firstName;


/*17. Select payments (check number and amount) of customers managed by employees
in the NYC office, classifying them by amount as:
 Over 50,000: 'Very high payment'
 Between 15,000 and 50,000: 'Medium payment'
 Less than 15,000: 'Low payment'*/
 
SELECT 
    pay.checkNumber,
    pay.amount,
    CASE
        WHEN pay.amount > 50000 THEN 'Very high payment'
        WHEN pay.amount BETWEEN 15000 AND 50000 THEN 'Medium payment'
        ELSE 'Low payment'
    END AS classification
FROM
    payments pay
        JOIN
    customers c ON pay.customerNumber = c.customerNumber
        JOIN
    employees emp ON c.salesRepEmployeeNumber = emp.employeeNumber
        JOIN
    offices o ON emp.officeCode = o.officeCode
WHERE
    o.city = 'NYC';

/*18. Show a list with the branch name (city), first name, and last name of employees
working there, ordered by branch and last name.*/

SELECT 
    o.city, emp.firstName, emp.lastName
FROM
    employees emp
        JOIN
    offices o ON emp.officeCode = o.officeCode
ORDER BY o.city , emp.lastName;


/*19. Show the office name of employees who have managed orders placed by the
customer "Atelier graphique."*/

SELECT DISTINCT
    offices.city AS officeName
FROM
    offices
        JOIN
    employees emp ON offices.officeCode = emp.officeCode
        JOIN
    customers c ON emp.employeeNumber = c.salesRepEmployeeNumber
        JOIN
    orders ON c.customerNumber = orders.customerNumber
WHERE
    c.customerName = 'Atelier graphique';


/*20. Show the first name, last name, and job title of employees who do not have the title
"Sales Rep." Add a column with their boss's full name. Employees without a boss
should also be listed.*/

SELECT 
    emp.firstName,
    emp.lastName,
    emp.jobTitle,
    CONCAT(j.firstName, ' ', j.lastName) AS bossName
FROM
    employees emp
        LEFT JOIN
    employees j ON emp.reportsTo = j.employeeNumber
WHERE
    emp.jobTitle NOT LIKE 'Sales Rep';


/*21. Show the name of all offices and the total amount of money in orders managed by
employees in each office.*/

SELECT 
    o.city as officeName,
    SUM(od.priceEach * od.quantityOrdered) AS totalAmount
FROM
    offices o
        JOIN
    employees emp ON o.officeCode = emp.officeCode
        JOIN
    customers c ON emp.employeeNumber = c.salesRepEmployeeNumber
        JOIN
    orders ord ON c.customerNumber = ord.customerNumber
        JOIN
    orderdetails od ON ord.orderNumber = od.orderNumber
GROUP BY o.city;


/*22. Show the name of Japanese customers who bought products of the "Classic Cars"
product line, and the first and last name of the employees who assigned to them.*/

SELECT DISTINCT
    c.customerName,
    emp.firstName AS employeeName,
    emp.lastName AS employeeLastName,
    c.country
FROM
    customers c
        JOIN
    employees emp ON c.salesRepEmployeeNumber = emp.employeeNumber
        JOIN
    orders ord ON c.customerNumber = ord.customerNumber
        JOIN
    orderdetails od ON ord.orderNumber = od.orderNumber
        JOIN
    products p ON od.productCode = p.productCode
WHERE
    c.country = 'Japan'
        AND p.productLine = 'Classic Cars';


/*23. Show the cities of offices (as office_city) that have at least one employee with five
assigned customers.*/
    
SELECT 
    offices.city AS office_city
FROM
    offices
WHERE
    EXISTS( SELECT 
            1
        FROM
            employees emp
                JOIN
            customers c ON emp.employeeNumber = c.salesRepEmployeeNumber
        WHERE
            offices.officeCode = emp.officeCode
        GROUP BY emp.employeeNumber
        HAVING COUNT(c.customerNumber) = 5);


/*24. Show the order number and date of orders for products of type "Planes," placed by
customers who have made exactly two orders and with orders in May 2024.*/

SELECT DISTINCT
    ord.orderNumber, ord.orderDate
FROM
    orders ord
        JOIN
    orderdetails od ON ord.orderNumber = od.orderNumber
        JOIN
    products p ON od.productCode = p.productCode
WHERE
    p.productLine = 'Planes'
        AND ord.orderDate BETWEEN '2024-05-01' AND '2024-05-31'
        AND ord.customerNumber IN (SELECT 
            customerNumber
        FROM
            orders
        GROUP BY customerNumber
        HAVING COUNT(*) = 2);

    
/*25. How many customers are there for each combination of office city and order status?*/

SELECT 
    offices.city,
    o.status,
    COUNT(DISTINCT c.customerNumber) AS numberOfCustomers
FROM
    offices
        JOIN
    employees emp ON offices.officeCode = emp.officeCode
        JOIN
    customers c ON emp.employeeNumber = c.salesRepEmployeeNumber
        JOIN
    orders o ON c.customerNumber = o.customerNumber
GROUP BY offices.city , o.status;







    



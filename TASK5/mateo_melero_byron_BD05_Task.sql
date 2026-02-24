-- Exercise 2
INSERT INTO payments values(124, 'H123', '2024-02-06', 845.00);
INSERT INTO payments values(151, 'H124', '2024-02-07', 70.00);
INSERT INTO payments values(112, 'H125', '2024-02-05', 1024.00);

-- Exercise 4
UPDATE classicmodels.orders 
SET 
    status = 'Cancelled',
    shippedDate = CURDATE(),
    comments = 'Order cancelled due to delay'
WHERE
    orderDate = '2003-09-28';

-- Exercise 5
UPDATE classicmodels.products 
SET 
    productName = CONCAT(productName, ' (code ', productCode, ')')
WHERE
    productLine = 'Trains';

-- Exercise 6
UPDATE classicmodels.products 
SET 
    buyPrice = buyPrice + (0.02 * buyPrice/100),
    MSRP = MSRP + (0.02 * MSRP/100)
WHERE
    quantityInStock > 500;

-- Exercise 7
DELETE pay FROM classicmodels.payments pay
        JOIN
    customers c ON c.customerNumber = pay.customerNumber
        JOIN
    employees emp ON emp.employeeNumber = c.salesRepEmployeeNumber 
WHERE
    emp.lastName = 'Patterson';

-- Exercise 8
DELETE c FROM classicmodels.customers c
        LEFT JOIN
    payments pay ON c.customerNumber = pay.customerNumber 
WHERE
    c.city = 'Lisboa'
    AND pay.customerNumber IS NULL;

-- Exercise 9
INSERT INTO employees 
	(employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
SELECT 
    c.customerNumber + 2000,
    c.contactLastName,
    c.contactFirstName,
    'x0000',
    'new@company.com',
    1,
    NULL,
    'Sales Rep'
FROM
    customers c;

-- Exercise 10
UPDATE orders o
        JOIN
    customers c ON c.customerNumber = o.customerNumber 
SET 
    status = 'Cancelled',
    shippedDate = CURDATE(),
    comments = 'Order cancelled by management'
WHERE
    c.contactFirstName LIKE '%Elizabeth%'
        AND c.contactLastName = 'Lincoln';
        
-- Version with trim()
UPDATE orders o
        JOIN
    customers c ON c.customerNumber = o.customerNumber 
SET 
    status = 'Cancelled',
    shippedDate = CURDATE(),
    comments = 'Order cancelled by management'
WHERE
    TRIM(c.contactFirstName) = 'Elizabeth'
        AND c.contactLastName = 'Lincoln';


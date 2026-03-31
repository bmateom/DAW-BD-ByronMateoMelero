-- TEST SCRIPTS

-- Exercise 1 Test

	-- Check if there is any employee with Job Title = Sales Manager.
	-- We check, for instance: officeCode = 6.
	SELECT employeeNumber, firstName, lastName, officeCode, jobTitle
	FROM employees
	WHERE officeCode = 6
	  AND jobTitle LIKE 'Sales Manager%';
	  
	-- There is one, so:
	INSERT INTO employees
	VALUES (100, 'Test', 'User', 'x1130', 'test@example.com', 6, 1002, 'Sales Manager');

	-- OK
	INSERT INTO employees values (999, 'Mateo', 'Byron', 'x1129','byronmateomelero@gmail.com', 6, null, 'VP Sales');


-- Exercise 2 Test

	-- First, we look for a customer with 3 active orders. We take as an example, customer with customerNumber = 103.
    SELECT * FROM customers WHERE customerNumber = 103;
    
	SELECT COUNT(*) AS active_orders
	FROM orders
	WHERE customerNumber = 103
	  AND status IN ('In Process', 'On Hold', 'Shipped');
      
      -- If we try to insert a new order with that customerNumber, it fails.
	INSERT INTO orders
	(orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber)
	VALUES (99901, '2026-03-31', '2026-04-10', NULL, 'In Process', 'Test order', 103);
    
    -- A valid case:
    SELECT * FROM customers WHERE customerNumber = 125;
    
	SELECT COUNT(*) AS active_orders
	FROM orders
	WHERE customerNumber = 125
	  AND status IN ('In Process', 'On Hold', 'Shipped');

	-- If we try to insert a new order, its a valid operation.
    INSERT INTO orders
	(orderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber)
	VALUES (99901, '2026-03-31', '2026-04-10', NULL, 'In Process', 'Test order', 125);

	-- We can check again with the previous query.
    

-- Exercise 3 Test

	-- Check a product has stock
	SELECT quantityInStock
	FROM products
	WHERE productCode = 'S10_1678';

	-- Valid Case: We try to insert an order detail into the table. 
	INSERT INTO orderdetails
	(orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
	VALUES (10100, 'S10_1678', 5, 100.00, 1);
    
    -- Product does not have stock.
    INSERT INTO orderdetails
	(orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
	VALUES (10100, 'TEST123', 5, 100.00, 1);
    
    -- Quantity exceeds stock (quantityInStock)
    SELECT * FROM products 
    WHERE productCode = 'S10_1678';
    
	INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
	VALUES (10100, 'S10_1678', 99999, 100, 1);


-- Exercise 4 Test

	-- Employee does not exist
	CALL delete_employee(99999);

	-- Employee does not have supervisor
    SELECT * FROM employees
    WHERE employeeNumber = 1002;
    
	CALL delete_employee(1002);

	-- OK
	SELECT * FROM employees
    WHERE employeeNumber = 1165;
    
	CALL delete_employee(1165);


-- Exercise 5 Test

	-- Valid Case
	CALL customers_sales_report('San Francisco', 2003, @report);
	SELECT @report;
    
	-- Case without data
	CALL customers_sales_report('San Francisco', 1999, @report);
	SELECT @report;


-- Exercise 6 Test

	-- Case with orders
	SELECT customer_summary(103);
    SELECT customer_summary(112);
	SELECT customer_summary(114);
    
    -- Case without orders
    SELECT customer_summary(99999);
    


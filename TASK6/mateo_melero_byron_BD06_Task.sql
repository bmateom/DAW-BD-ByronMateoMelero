-- Exercise 1

DELIMITER $$

CREATE 
    TRIGGER  before_insert_employees
 BEFORE INSERT ON employees FOR EACH ROW 
    BEGIN 
		DECLARE total integer;
        
		IF new.jobTitle LIKE 'Sales Manager%' THEN
			SELECT COUNT(*) INTO total
            FROM employees
            WHERE officeCode = NEW.officeCode
            AND jobTitle LIKE 'Sales Manager%';
            
            IF total > 0 THEN
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Only one Sales Manager is allowed per office';
            END IF;
            
        END IF;
    END$$

DELIMITER ;


-- Exercise 2

DELIMITER $$

CREATE
	TRIGGER before_insert_orders
    BEFORE INSERT ON orders 
    FOR EACH ROW
BEGIN
    DECLARE total integer;
    IF new.status in ('In Process', 'On Hold', 'Shipped') THEN
		SELECT COUNT(*) INTO total 
        FROM orders
        WHERE customerNumber = new.customerNumber
        AND status in('In Process', 'On Hold', 'Shipped');
        
        IF total >= 3 THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A customer cannot have more than 3 active orders';
        END IF;
    END IF;
END$$
    
DELIMITER ;


-- Exercise 3

DELIMITER $$

CREATE
	TRIGGER before_insert_stock 
	BEFORE INSERT ON orderdetails
	FOR EACH ROW
BEGIN
	DECLARE stock integer;
    
    SELECT quantityInStock INTO stock
    FROM products
    WHERE productCode = NEW.productCode;
    
    IF NEW.quantityOrdered > stock THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Insufficient stock to fulfill the order';
    END IF;
    
    IF stock IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The product must be in stock to place an order';
    END IF;
    
END$$

DELIMITER ;


-- Exercise 4

DELIMITER $$

CREATE PROCEDURE delete_employee(IN empNumber integer)
BEGIN
	DECLARE supervisor integer;
	DECLARE total integer;

		SELECT COUNT(*) INTO total
		FROM employees
		WHERE employeeNumber = empNumber;
		
		IF total = 0 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'The employee does not exist';
		END IF;

		SELECT reportsTo INTO supervisor
		FROM employees
		WHERE employeeNumber = empNumber;
		
		IF supervisor IS NULL THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'The employee is the President and cannot be deleted';
		END IF;
		
		UPDATE customers 
		SET salesRepEmployeeNumber = supervisor
		WHERE salesRepEmployeeNumber = empNumber;
		
		UPDATE employees 
		SET reportsTo = supervisor
		WHERE reportsTo = empNumber;
		
		DELETE FROM employees
		where employeeNumber = empNumber;
    
END$$

DELIMITER ;

-- Exercise 5

DELIMITER $$

CREATE PROCEDURE customers_sales_report(
	IN office_name VARCHAR(50), 
	IN year_param integer,
	OUT report LONGTEXT)
BEGIN
    DECLARE v_month integer;
    DECLARE v_employee VARCHAR(100);
    DECLARE v_customer VARCHAR(100);
    DECLARE v_total DECIMAL(10,2);
    
    DECLARE finished int default 0; -- control end of cursor
    
    DECLARE sales_cursor CURSOR FOR
		SELECT month(o.orderDate) as sale_month, 
			CONCAT(emp.firstName, ' ', emp.lastName) AS employee_name,
			c.customerName,
			SUM(od.quantityOrdered * od.priceEach) as monthly_sales
		FROM offices
		JOIN employees emp ON offices.officeCode = emp.officeCode
		JOIN customers c ON emp.employeeNumber = c.salesRepEmployeeNumber
		JOIN orders o ON c.customerNumber = o.customerNumber
		JOIN orderdetails od ON o.orderNumber = od.orderNumber
		WHERE offices.city = office_name
			AND year(o.orderDate) = year_param
		GROUP BY sale_month, emp.employeeNumber, c.customerNumber
		ORDER BY sale_month, employee_name;
	
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    
    SET report = '';
    
    OPEN sales_cursor;
    read_loop: LOOP
		FETCH sales_cursor INTO v_month, v_employee, v_customer, v_total;
		IF finished = 1 THEN
			LEAVE read_loop;
		END IF;
        
		SET report = CONCAT(
			report, '** Month: ', v_month,
			' ** Employee: ', v_employee,
			' ** Customer: ', v_customer,
			' ** Total Sales: ', v_total,
			CHAR(10)
			);
	END LOOP;
    CLOSE sales_cursor;
    
    IF report = '' THEN
		SET report = 'No data is available';
    END IF;
		

END$$

DELIMITER ;

-- Exercise 6

DELIMITER $$

CREATE FUNCTION customer_summary(cNum integer)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	DECLARE v_orders integer;
    DECLARE v_products integer;
    DECLARE v_result VARCHAR(100);
    
    -- Total of orders
    SELECT COUNT(*) INTO v_orders
    FROM orders
    WHERE customerNumber = cNum;
    
	-- Total of products
	SELECT COUNT(DISTINCT productCode) INTO v_products
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE o.customerNumber = cNum;
	
    IF v_orders = 0 THEN
		RETURN 'No orders or products';
    END IF;
    
    SET v_result = CONCAT(
    v_orders, ' order/s and ', v_products, ' product/s');
    
    RETURN v_result;
    
END$$

DELIMITER ;

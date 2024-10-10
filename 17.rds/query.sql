CREATE DATABASE company;
USE company;

CREATE TABLE employees (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    salary INT(10) NOT NULL
);

INSERT INTO employees (name, address, salary) 
VALUES
('Linh', 'Quan 12, TPHCM', '500000'),
('Chien', 'Quan 1, TPHCM', '100000'),
('Thong', 'Quan 9, TPHCM', '2000000'),
('Hai Huy', 'Quan 13, TPHCM', '500000');

SELECT * FROM employees;

update employees  set salary = 7000000 WHERE id =1;
DELETE FROM employees WHERE id = 2;

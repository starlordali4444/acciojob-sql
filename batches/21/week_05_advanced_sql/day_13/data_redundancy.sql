create SCHEMA day_13;

set search_path to day_13;

show search_path;


-- Creating an unnormalized table with redundancy
CREATE TABLE student_courses_bad (
    student_id INT,
    student_name VARCHAR(100),
    student_email VARCHAR(100),
    student_phone VARCHAR(15),
    course_id INT,
    course_name VARCHAR(100),
    instructor_name VARCHAR(100),
    instructor_email VARCHAR(100)
);

-- Inserting data (notice the redundancy)
INSERT INTO student_courses_bad VALUES
(101, 'Rahul Sharma', 'rahul@email.com', '9876543210', 1, 'SQL Basics', 'Siraj Ali', 'siraj@accio.com'),
(101, 'Rahul Sharma', 'rahul@email.com', '9876543210', 2, 'Python Programming', 'Priya Singh', 'priya@accio.com'),
(102, 'Priya Patel', 'priya.p@email.com', '9876543211', 1, 'SQL Basics', 'Siraj Ali', 'siraj@accio.com'),
(103, 'Amit Kumar', 'amit@email.com', '9876543212', 3, 'Data Analytics', 'Siraj Ali', 'siraj@accio.com');

SELECT * FROM student_courses_bad;

-- 🚫 Problems Identified:
--     Redundancy: Rahul Sharma's details repeated twice
--     Redundancy: Siraj Ali's details repeated three times
--     Update Anomaly: If Rahul changes his phone number, must update multiple rows
--     Deletion Anomaly: If Amit drops 'Data Analytics', we lose instructor information

-- Unnormalized restaurant order table
CREATE TABLE restaurant_orders_bad (
    order_id INT,
    order_date DATE,
    customer_name VARCHAR(100),
    customer_phone VARCHAR(15),
    customer_address TEXT,
    item_name VARCHAR(100),
    item_price NUMERIC(8,2),
    quantity INT,
    delivery_boy_name VARCHAR(100),
    delivery_boy_phone VARCHAR(15)
);

-- Sample data showing redundancy
INSERT INTO restaurant_orders_bad VALUES
(1001, '2025-01-15', 'Sneha Reddy', '9988776655', 'MG Road, Bangalore', 'Paneer Tikka', 250.00, 2, 'Raju', '9876543210'),
(1001, '2025-01-15', 'Sneha Reddy', '9988776655', 'MG Road, Bangalore', 'Butter Naan', 40.00, 4, 'Raju', '9876543210'),
(1002, '2025-01-15', 'Vikram Joshi', '9988776656', 'Indiranagar, Bangalore', 'Biryani', 300.00, 1, 'Raju', '9876543210');

SELECT * FROM restaurant_orders_bad;

-- 🚫 Problems:
--     Customer details repeated for each item in the same order
--     Delivery boy details repeated across multiple orders
--     Insertion Anomaly: Can't add a new customer without an order


-- Complex unnormalized inventory table
CREATE TABLE ecommerce_inventory_bad (
    product_id INT,
    product_name VARCHAR(150),
    category VARCHAR(50),
    brand VARCHAR(50),
    supplier_name VARCHAR(100),
    supplier_email VARCHAR(100),
    supplier_phone VARCHAR(15),
    supplier_city VARCHAR(50),
    warehouse_name VARCHAR(100),
    warehouse_city VARCHAR(50),
    stock_quantity INT,
    price NUMERIC(10,2)
);

INSERT INTO ecommerce_inventory_bad VALUES
(501, 'Samsung Galaxy S23', 'Smartphones', 'Samsung', 'Tech Distributors India', 'info@techd.com', '9123456789', 'Mumbai', 'Mumbai Central Warehouse', 'Mumbai', 150, 79999.00),
(501, 'Samsung Galaxy S23', 'Smartphones', 'Samsung', 'Tech Distributors India', 'info@techd.com', '9123456789', 'Mumbai', 'Delhi North Warehouse', 'Delhi', 200, 79999.00),
(502, 'iPhone 15', 'Smartphones', 'Apple', 'Tech Distributors India', 'info@techd.com', '9123456789', 'Mumbai', 'Mumbai Central Warehouse', 'Mumbai', 100, 89999.00);

SELECT * FROM ecommerce_inventory_bad;

-- Query showing update anomaly
SELECT product_name, supplier_name, supplier_email, COUNT(*) as occurrences
FROM ecommerce_inventory_bad
GROUP BY product_name, supplier_name, supplier_email;


-- 🚫 Problems:
-- 	Product details repeated for each warehouse location
-- 	Supplier information duplicated across products
-- 	If supplier changes email, must update multiple rows
-- 	Deletion Anomaly: If all stock of iPhone 15 sold from Mumbai warehouse, we might lose product details

-- Unnormalized hospital management system
CREATE TABLE hospital_records_bad (
    patient_id INT,
    patient_name VARCHAR(100),
    patient_age INT,
    patient_address TEXT,
    doctor_id INT,
    doctor_name VARCHAR(100),
    doctor_specialization VARCHAR(100),
    doctor_phone VARCHAR(15),
    appointment_date DATE,
    diagnosis TEXT,
    medicine_prescribed VARCHAR(200),
    medicine_dosage VARCHAR(100)
);

INSERT INTO hospital_records_bad VALUES
(2001, 'Rajesh Kumar', 45, 'Sector 21, Noida', 301, 'Dr. Mehta', 'Cardiology', '9876501234', '2025-01-10', 'High BP', 'Amlodipine', '5mg daily'),
(2001, 'Rajesh Kumar', 45, 'Sector 21, Noida', 301, 'Dr. Mehta', 'Cardiology', '9876501234', '2025-01-10', 'High BP', 'Aspirin', '75mg daily'),
(2002, 'Sunita Devi', 38, 'Dwarka, Delhi', 302, 'Dr. Sharma', 'General Medicine', '9876501235', '2025-01-11', 'Fever', 'Paracetamol', '500mg thrice daily'),
(2001, 'Rajesh Kumar', 45, 'Sector 21, Noida', 303, 'Dr. Verma', 'Neurology', '9876501236', '2025-01-20', 'Migraine', 'Sumatriptan', '50mg as needed');

SELECT * FROM hospital_records_bad;

-- 🚫 Problems:
-- 	Patient details repeated for each medicine and each appointment
-- 	Doctor information duplicated
-- 	Can't add a new doctor without a patient appointment (Insertion Anomaly)


-- Complex banking system with multiple anomalies
CREATE TABLE bank_transactions_bad (
    transaction_id SERIAL PRIMARY KEY,
    account_number VARCHAR(20),
    account_holder_name VARCHAR(100),
    account_type VARCHAR(20),
    account_holder_pan VARCHAR(10),
    account_holder_phone VARCHAR(15),
    account_holder_email VARCHAR(100),
    branch_code VARCHAR(10),
    branch_name VARCHAR(100),
    branch_manager VARCHAR(100),
    branch_city VARCHAR(50),
    transaction_date DATE,
    transaction_type VARCHAR(20),
    amount NUMERIC(12,2),
    beneficiary_account VARCHAR(20),
    beneficiary_name VARCHAR(100),
    beneficiary_bank VARCHAR(100),
    beneficiary_ifsc VARCHAR(11)
);

INSERT INTO bank_transactions_bad VALUES
(DEFAULT, 'ACC1001', 'Anil Kapoor', 'Savings', 'ABCDE1234F', '9876543210', 'anil@email.com', 'BR001', 'Connaught Place', 'Mr. Gupta', 'Delhi', '2025-01-15', 'NEFT', 5000.00, 'ACC2001', 'Deepak Verma', 'ICICI Bank', 'ICIC0001234'),
(DEFAULT, 'ACC1001', 'Anil Kapoor', 'Savings', 'ABCDE1234F', '9876543210', 'anil@email.com', 'BR001', 'Connaught Place', 'Mr. Gupta', 'Delhi', '2025-01-16', 'UPI', 1500.00, 'ACC3001', 'Swati Shah', 'HDFC Bank', 'HDFC0002345'),
(DEFAULT, 'ACC2001', 'Deepak Verma', 'Current', 'FGHIJ5678K', '9876543211', 'deepak@email.com', 'BR002', 'Karol Bagh', 'Ms. Sharma', 'Delhi', '2025-01-17', 'IMPS', 10000.00, 'ACC1001', 'Anil Kapoor', 'SBI', 'SBIN0000123');

-- Demonstrating update anomaly
SELECT account_number, account_holder_name, account_holder_phone, 
       COUNT(*) as transaction_count
FROM bank_transactions_bad
GROUP BY account_number, account_holder_name, account_holder_phone;

-- Demonstrating redundancy
SELECT branch_code, branch_name, branch_manager, COUNT(*) as occurrences
FROM bank_transactions_bad
GROUP BY branch_code, branch_name, branch_manager;


-- 🚫 Complex Problems:
-- 		Account holder details repeated for every transaction (massive redundancy)
-- 		Branch information duplicated extensively
-- 		Beneficiary details stored redundantly
-- 		Update Anomaly: Changing account holder phone requires updating hundreds of transaction records
-- 		Deletion Anomaly: Deleting all transactions of a branch loses branch information
-- 		Insertion Anomaly: Cannot add branch details without a transaction


-- Ultra-complex unnormalized EdTech system
CREATE TABLE edtech_platform_nightmare (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT,
    student_name VARCHAR(100),
    student_email VARCHAR(100),
    student_phone VARCHAR(15),
    student_dob DATE,
    student_city VARCHAR(50),
    student_state VARCHAR(50),
    parent_name VARCHAR(100),
    parent_phone VARCHAR(15),
    parent_email VARCHAR(100),
    course_id INT,
    course_name VARCHAR(150),
    course_category VARCHAR(50),
    course_duration_weeks INT,
    course_fee NUMERIC(10,2),
    instructor_id INT,
    instructor_name VARCHAR(100),
    instructor_email VARCHAR(100),
    instructor_specialization VARCHAR(100),
    instructor_experience_years INT,
    batch_id INT,
    batch_name VARCHAR(50),
    batch_start_date DATE,
    batch_end_date DATE,
    batch_timing VARCHAR(50),
    class_days VARCHAR(50),
    enrollment_date DATE,
    payment_status VARCHAR(20),
    amount_paid NUMERIC(10,2),
    payment_mode VARCHAR(30),
    discount_applied NUMERIC(6,2),
    referral_code VARCHAR(20),
    assignment_1_score INT,
    assignment_2_score INT,
    assignment_3_score INT,
    project_score INT,
    attendance_percentage NUMERIC(5,2)
);

INSERT INTO edtech_platform_nightmare VALUES
(DEFAULT, 5001, 'Arjun Malhotra', 'arjun@email.com', '9876543210', '2000-05-15', 'Jaipur', 'Rajasthan', 
'Rakesh Malhotra', '9876543211', 'rakesh@email.com', 101, 'Full Stack Development', 'Programming', 24, 
50000.00, 201, 'Siraj Ali', 'siraj@accio.com', 'SQL & Backend', 8, 301, 'Batch-Jan-2025-Morning', 
'2025-01-10', '2025-06-10', '10 AM - 1 PM', 'Mon-Wed-Fri', '2025-01-05', 'Completed', 50000.00, 
'UPI', 10.00, 'REF123', 85, 90, 88, 92, 95.5),

(DEFAULT, 5001, 'Arjun Malhotra', 'arjun@email.com', '9876543210', '2000-05-15', 'Jaipur', 'Rajasthan', 
'Rakesh Malhotra', '9876543211', 'rakesh@email.com', 102, 'Data Analytics', 'Analytics', 12, 
30000.00, 202, 'Priya Singh', 'priya@accio.com', 'Data Science', 5, 302, 'Batch-Feb-2025-Evening', 
'2025-02-01', '2025-04-30', '6 PM - 9 PM', 'Tue-Thu-Sat', '2025-01-25', 'Pending', 15000.00, 
'Credit Card', 0.00, NULL, NULL, NULL, NULL, NULL, NULL),

(DEFAULT, 5002, 'Meera Iyer', 'meera@email.com', '9876543212', '1999-08-20', 'Chennai', 'Tamil Nadu', 
'Suresh Iyer', '9876543213', 'suresh@email.com', 101, 'Full Stack Development', 'Programming', 24, 
50000.00, 201, 'Siraj Ali', 'siraj@accio.com', 'SQL & Backend', 8, 301, 'Batch-Jan-2025-Morning', 
'2025-01-10', '2025-06-10', '10 AM - 1 PM', 'Mon-Wed-Fri', '2025-01-06', 'Completed', 45000.00, 
'Net Banking', 10.00, 'REF456', 90, 87, 92, 95, 98.0);

-- Query to show massive redundancy
SELECT course_name, instructor_name, batch_name, COUNT(*) as enrollments
FROM edtech_platform_nightmare
GROUP BY course_name, instructor_name, batch_name;

-- Show student data duplication
SELECT student_id, student_name, COUNT(*) as course_enrollments
FROM edtech_platform_nightmare
GROUP BY student_id, student_name;

-- Calculate storage waste due to redundancy
SELECT 
    'Total Records' as metric,
    COUNT(*) as value
FROM edtech_platform_nightmare
UNION ALL
SELECT 
    'Unique Students' as metric,
    COUNT(DISTINCT student_id) as value
FROM edtech_platform_nightmare
UNION ALL
SELECT 
    'Unique Courses' as metric,
    COUNT(DISTINCT course_id) as value
FROM edtech_platform_nightmare
UNION ALL
SELECT 
    'Unique Instructors' as metric,
    COUNT(DISTINCT instructor_id) as value
FROM edtech_platform_nightmare;


-- 🚫 MASSIVE Problems:
-- 		43 columns in a single table!
-- 		Student details repeated for every course enrollment
-- 		Parent details duplicated unnecessarily
-- 		Course information repeated for every enrollment
-- 		Instructor data duplicated across multiple batches
-- 		Batch information repeated for every student
-- 		Update Anomaly: If student changes phone, must update across all enrollments
-- 		Update Anomaly: If course fee changes, must update all enrolled students
-- 		Update Anomaly: If instructor changes email, update across all batches
-- 		Deletion Anomaly: If last student drops from a batch, we lose batch information
-- 		Insertion Anomaly: Cannot add course details without student enrollment
-- 		Storage Waste: Gigabytes of redundant data

















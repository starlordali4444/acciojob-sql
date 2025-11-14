-- THIRD NORMAL FORM (3NF)

	-- A table is in Third Normal Form (3NF) if:
	
		-- It is already in 2NF
		-- It has NO transitive dependencies (non-key attributes should not depend on other non-key attributes)
		
	-- ✅ Rules:
		
		-- Every non-key attribute must depend directly on the primary key
		-- Non-key attributes should NOT depend on other non-key attributes
		-- All attributes must be functionally dependent only on the primary key
		
	-- 🎯 Key Concept:
		-- Transitive Dependency = When A → B and B → C, then A → C (indirect dependency)
		-- Example: student_id → department_id → department_name (department_name transitively depends on student_id through department_id)


-- ❌ NOT in 3NF: Has transitive dependency
-- Primary Key: emp_id
-- Transitive Dependency: emp_id → dept_id → dept_name, dept_head
CREATE TABLE employees_not_3nf (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    emp_email VARCHAR(100),
    salary NUMERIC(10,2),
    dept_id INT,                    -- Depends on emp_id (direct)
    dept_name VARCHAR(100),         -- TRANSITIVE: Depends on dept_id, not emp_id directly
    dept_head VARCHAR(100),         -- TRANSITIVE: Depends on dept_id, not emp_id directly
    dept_location VARCHAR(100)      -- TRANSITIVE: Depends on dept_id, not emp_id directly
);

INSERT INTO employees_not_3nf VALUES
(101, 'Rahul Sharma', 'rahul@company.com', 75000.00, 10, 'IT', 'Mr. Gupta', 'Building A'),
(102, 'Priya Patel', 'priya@company.com', 68000.00, 10, 'IT', 'Mr. Gupta', 'Building A'),
(103, 'Amit Kumar', 'amit@company.com', 82000.00, 20, 'Finance', 'Ms. Desai', 'Building B'),
(104, 'Sneha Reddy', 'sneha@company.com', 70000.00, 30, 'HR', 'Mr. Sharma', 'Building C');

SELECT * FROM employees_not_3nf;

-- ❌ PROBLEMS:
-- 1. Department details repeated for each employee in that department
-- 2. If department head changes, must update all employees in that department
-- 3. Cannot add new department without an employee
-- 4. Deleting all employees from a department loses department information

-- ✅ SOLUTION: Convert to 3NF by removing transitive dependencies
CREATE TABLE departments_3nf (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100),
    dept_head VARCHAR(100),
    dept_location VARCHAR(100)
);

CREATE TABLE employees_3nf (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    emp_email VARCHAR(100),
    salary NUMERIC(10,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments_3nf(dept_id)
);

-- Insert normalized data
INSERT INTO departments_3nf VALUES
(10, 'IT', 'Mr. Gupta', 'Building A'),
(20, 'Finance', 'Ms. Desai', 'Building B'),
(30, 'HR', 'Mr. Sharma', 'Building C');

INSERT INTO employees_3nf VALUES
(101, 'Rahul Sharma', 'rahul@company.com', 75000.00, 10),
(102, 'Priya Patel', 'priya@company.com', 68000.00, 10),
(103, 'Amit Kumar', 'amit@company.com', 82000.00, 20),
(104, 'Sneha Reddy', 'sneha@company.com', 70000.00, 30);

-- Query: Employee details with department information
SELECT 
    e.emp_id,
    e.emp_name,
    e.emp_email,
    e.salary,
    d.dept_name,
    d.dept_head,
    d.dept_location
FROM employees_3nf e
JOIN departments_3nf d ON e.dept_id = d.dept_id;

-- Now we can easily update department head without touching employee records!
UPDATE departments_3nf 
SET dept_head = 'Mr. Verma' 
WHERE dept_id = 10;

-- Query: Department-wise employee count and average salary
SELECT 
    d.dept_name,
    d.dept_head,
    COUNT(e.emp_id) as employee_count,
    AVG(e.salary) as avg_salary,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary
FROM departments_3nf d
LEFT JOIN employees_3nf e ON d.dept_id = e.dept_id
GROUP BY d.dept_name, d.dept_head;


-- ❌ NOT in 3NF: Multiple transitive dependencies
-- Primary Key: enrollment_id
-- Transitive chains:
-- enrollment_id → student_id → college_id → college_name, college_city
-- enrollment_id → course_id → department_id → department_name, dept_head
CREATE TABLE student_enrollments_not_3nf (
    enrollment_id INT PRIMARY KEY,
    enrollment_date DATE,
    semester VARCHAR(20),
    student_id INT,
    student_name VARCHAR(100),
    student_email VARCHAR(100),
    college_id INT,                 -- TRANSITIVE: via student_id
    college_name VARCHAR(150),      -- TRANSITIVE: via student_id → college_id
    college_city VARCHAR(50),       -- TRANSITIVE: via student_id → college_id
    course_id INT,
    course_name VARCHAR(100),
    credits INT,
    department_id INT,              -- TRANSITIVE: via course_id
    department_name VARCHAR(100),   -- TRANSITIVE: via course_id → department_id
    dept_head VARCHAR(100),         -- TRANSITIVE: via course_id → department_id
    grade CHAR(2)
);

INSERT INTO student_enrollments_not_3nf VALUES
(5001, '2025-01-10', 'Spring 2025', 101, 'Arjun Malhotra', 'arjun@email.com', 1, 
 'Delhi University', 'Delhi', 201, 'Data Structures', 4, 10, 'Computer Science', 'Dr. Sharma', NULL),
(5002, '2025-01-10', 'Spring 2025', 101, 'Arjun Malhotra', 'arjun@email.com', 1,
 'Delhi University', 'Delhi', 202, 'Database Systems', 4, 10, 'Computer Science', 'Dr. Sharma', NULL),
(5003, '2025-01-11', 'Spring 2025', 102, 'Meera Iyer', 'meera@email.com', 2,
 'Mumbai University', 'Mumbai', 201, 'Data Structures', 4, 10, 'Computer Science', 'Dr. Sharma', NULL);

SELECT * FROM student_enrollments_not_3nf;

-- ✅ SOLUTION: Convert to 3NF by breaking transitive dependencies
CREATE TABLE colleges_3nf (
    college_id INT PRIMARY KEY,
    college_name VARCHAR(150),
    college_city VARCHAR(50)
);

CREATE TABLE students_college_3nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    student_email VARCHAR(100),
    college_id INT,
    FOREIGN KEY (college_id) REFERENCES colleges_3nf(college_id)
);

CREATE TABLE departments_college_3nf (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    dept_head VARCHAR(100)
);

CREATE TABLE courses_college_3nf (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    credits INT,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments_college_3nf(department_id)
);

CREATE TABLE enrollments_college_3nf (
    enrollment_id INT PRIMARY KEY,
    enrollment_date DATE,
    semester VARCHAR(20),
    student_id INT,
    course_id INT,
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES students_college_3nf(student_id),
    FOREIGN KEY (course_id) REFERENCES courses_college_3nf(course_id)
);

-- Insert normalized data
INSERT INTO colleges_3nf VALUES
(1, 'Delhi University', 'Delhi'),
(2, 'Mumbai University', 'Mumbai');

INSERT INTO students_college_3nf VALUES
(101, 'Arjun Malhotra', 'arjun@email.com', 1),
(102, 'Meera Iyer', 'meera@email.com', 2);

INSERT INTO departments_college_3nf VALUES
(10, 'Computer Science', 'Dr. Sharma');

INSERT INTO courses_college_3nf VALUES
(201, 'Data Structures', 4, 10),
(202, 'Database Systems', 4, 10);

INSERT INTO enrollments_college_3nf VALUES
(5001, '2025-01-10', 'Spring 2025', 101, 201, NULL),
(5002, '2025-01-10', 'Spring 2025', 101, 202, NULL),
(5003, '2025-01-11', 'Spring 2025', 102, 201, NULL);

-- Complex Query: Complete enrollment details
SELECT 
    e.enrollment_id,
    s.student_name,
    s.student_email,
    col.college_name,
    col.college_city,
    c.course_name,
    c.credits,
    d.department_name,
    d.dept_head,
    e.semester,
    e.grade
FROM enrollments_college_3nf e
JOIN students_college_3nf s ON e.student_id = s.student_id
JOIN colleges_3nf col ON s.college_id = col.college_id
JOIN courses_college_3nf c ON e.course_id = c.course_id
JOIN departments_college_3nf d ON c.department_id = d.department_id;

-- Benefits: Update department head in ONE place
UPDATE departments_college_3nf 
SET dept_head = 'Dr. Verma' 
WHERE department_id = 10;



-- ❌ NOT in 3NF: Complex transitive dependencies
-- Multiple transitive chains:
-- appointment_id → patient_id → insurance_id → insurance_company, coverage_details
-- appointment_id → doctor_id → specialty_id → specialty_name, dept_name
-- appointment_id → hospital_id → city_id → city, state
CREATE TABLE hospital_appointments_not_3nf (
    appointment_id INT PRIMARY KEY,
    appointment_date DATE,
    appointment_time TIME,
    appointment_status VARCHAR(20),
    patient_id INT,
    patient_name VARCHAR(100),
    patient_phone VARCHAR(15),
    patient_dob DATE,
    insurance_id INT,               -- TRANSITIVE: via patient_id
    insurance_company VARCHAR(100), -- TRANSITIVE: via patient_id → insurance_id
    insurance_policy_number VARCHAR(50), -- TRANSITIVE: via patient_id → insurance_id
    coverage_amount NUMERIC(12,2),  -- TRANSITIVE: via patient_id → insurance_id
    doctor_id INT,
    doctor_name VARCHAR(100),
    doctor_phone VARCHAR(15),
    specialty_id INT,               -- TRANSITIVE: via doctor_id
    specialty_name VARCHAR(100),    -- TRANSITIVE: via doctor_id → specialty_id
    dept_name VARCHAR(100),         -- TRANSITIVE: via doctor_id → specialty_id
    hospital_id INT,
    hospital_name VARCHAR(150),
    city_id INT,                    -- TRANSITIVE: via hospital_id
    city VARCHAR(50),               -- TRANSITIVE: via hospital_id → city_id
    state VARCHAR(50),              -- TRANSITIVE: via hospital_id → city_id
    consultation_fee NUMERIC(8,2),
    diagnosis TEXT
);

INSERT INTO hospital_appointments_not_3nf VALUES
(7001, '2025-01-20', '10:00:00', 'Completed', 3001, 'Ramesh Singh', '9876543210', '1970-05-15',
 401, 'Star Health Insurance', 'POL12345', 500000.00, 501, 'Dr. Mehta', '9876501234',
 601, 'Cardiology', 'Cardiac Sciences', 701, 'Apollo Hospital', 801, 'Delhi', 'Delhi',
 1500.00, 'High Blood Pressure'),
(7002, '2025-01-20', '11:00:00', 'Scheduled', 3002, 'Sunita Devi', '9876543211', '1985-08-20',
 402, 'ICICI Lombard', 'POL67890', 300000.00, 502, 'Dr. Sharma', '9876501235',
 602, 'General Medicine', 'Internal Medicine', 701, 'Apollo Hospital', 801, 'Delhi', 'Delhi',
 1000.00, NULL),
(7003, '2025-01-21', '14:00:00', 'Scheduled', 3001, 'Ramesh Singh', '9876543210', '1970-05-15',
 401, 'Star Health Insurance', 'POL12345', 500000.00, 503, 'Dr. Verma', '9876501236',
 603, 'Neurology', 'Neuro Sciences', 702, 'Fortis Hospital', 802, 'Mumbai', 'Maharashtra',
 2000.00, NULL);

SELECT * FROM hospital_appointments_not_3nf;

-- ✅ SOLUTION: Convert to 3NF with proper decomposition
CREATE TABLE insurance_companies_3nf (
    insurance_id INT PRIMARY KEY,
    insurance_company VARCHAR(100),
    coverage_amount NUMERIC(12,2)
);

CREATE TABLE patients_health_3nf (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    patient_phone VARCHAR(15),
    patient_dob DATE,
    insurance_id INT,
    insurance_policy_number VARCHAR(50),
    FOREIGN KEY (insurance_id) REFERENCES insurance_companies_3nf(insurance_id)
);

CREATE TABLE medical_specialties_3nf (
    specialty_id INT PRIMARY KEY,
    specialty_name VARCHAR(100),
    dept_name VARCHAR(100)
);

CREATE TABLE doctors_health_3nf (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100),
    doctor_phone VARCHAR(15),
    specialty_id INT,
    FOREIGN KEY (specialty_id) REFERENCES medical_specialties_3nf(specialty_id)
);

CREATE TABLE cities_health_3nf (
    city_id INT PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE hospitals_3nf (
    hospital_id INT PRIMARY KEY,
    hospital_name VARCHAR(150),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES cities_health_3nf(city_id)
);

CREATE TABLE appointments_health_3nf (
    appointment_id INT PRIMARY KEY,
    appointment_date DATE,
    appointment_time TIME,
    appointment_status VARCHAR(20),
    patient_id INT,
    doctor_id INT,
    hospital_id INT,
    consultation_fee NUMERIC(8,2),
    diagnosis TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients_health_3nf(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors_health_3nf(doctor_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals_3nf(hospital_id)
);

-- Insert normalized data
INSERT INTO insurance_companies_3nf VALUES
(401, 'Star Health Insurance', 500000.00),
(402, 'ICICI Lombard', 300000.00);

INSERT INTO patients_health_3nf VALUES
(3001, 'Ramesh Singh', '9876543210', '1970-05-15', 401, 'POL12345'),
(3002, 'Sunita Devi', '9876543211', '1985-08-20', 402, 'POL67890');

INSERT INTO medical_specialties_3nf VALUES
(601, 'Cardiology', 'Cardiac Sciences'),
(602, 'General Medicine', 'Internal Medicine'),
(603, 'Neurology', 'Neuro Sciences');

INSERT INTO doctors_health_3nf VALUES
(501, 'Dr. Mehta', '9876501234', 601),
(502, 'Dr. Sharma', '9876501235', 602),
(503, 'Dr. Verma', '9876501236', 603);

INSERT INTO cities_health_3nf VALUES
(801, 'Delhi', 'Delhi'),
(802, 'Mumbai', 'Maharashtra');

INSERT INTO hospitals_3nf VALUES
(701, 'Apollo Hospital', 801),
(702, 'Fortis Hospital', 802);

INSERT INTO appointments_health_3nf VALUES
(7001, '2025-01-20', '10:00:00', 'Completed', 3001, 501, 701, 1500.00, 'High Blood Pressure'),
(7002, '2025-01-20', '11:00:00', 'Scheduled', 3002, 502, 701, 1000.00, NULL),
(7003, '2025-01-21', '14:00:00', 'Scheduled', 3001, 503, 702, 2000.00, NULL);

-- MEGA QUERY: Complete appointment details
SELECT 
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.appointment_status,
    p.patient_name,
    p.patient_phone,
    ins.insurance_company,
    p.insurance_policy_number,
    ins.coverage_amount,
    d.doctor_name,
    ms.specialty_name,
    ms.dept_name,
    h.hospital_name,
    c.city,
    c.state,
    a.consultation_fee,
    a.diagnosis
FROM appointments_health_3nf a
JOIN patients_health_3nf p ON a.patient_id = p.patient_id
JOIN insurance_companies_3nf ins ON p.insurance_id = ins.insurance_id
JOIN doctors_health_3nf d ON a.doctor_id = d.doctor_id
JOIN medical_specialties_3nf ms ON d.specialty_id = ms.specialty_id
JOIN hospitals_3nf h ON a.hospital_id = h.hospital_id
JOIN cities_health_3nf c ON h.city_id = c.city_id;

-- Analytics: Doctor workload by specialty
SELECT 
    ms.specialty_name,
    ms.dept_name,
    d.doctor_name,
    COUNT(a.appointment_id) as total_appointments,
    SUM(CASE WHEN a.appointment_status = 'Completed' THEN 1 ELSE 0 END) as completed,
    SUM(CASE WHEN a.appointment_status = 'Scheduled' THEN 1 ELSE 0 END) as scheduled,
    SUM(a.consultation_fee) as total_revenue
FROM doctors_health_3nf d
JOIN medical_specialties_3nf ms ON d.specialty_id = ms.specialty_id
LEFT JOIN appointments_health_3nf a ON d.doctor_id = a.doctor_id
GROUP BY ms.specialty_name, ms.dept_name, d.doctor_name
ORDER BY total_appointments DESC;



-- ❌ NOT in 3NF: Ultra-complex with multiple transitive dependency chains
-- Transitive chains:
-- property_id → owner_id → owner_tax_id → tax_zone, tax_rate
-- property_id → builder_id → builder_registration → regulatory_authority
-- property_id → locality_id → pin_code → post_office, delivery_zone
-- property_id → amenity_package_id → gym_type, pool_type, security_level
CREATE TABLE real_estate_properties_not_3nf (
    property_id INT PRIMARY KEY,
    property_name VARCHAR(200),
    property_type VARCHAR(50),
    total_area_sqft INT,
    construction_year INT,
    listing_date DATE,
    listing_price NUMERIC(15,2),
    property_status VARCHAR(20),
    owner_id INT,
    owner_name VARCHAR(100),
    owner_phone VARCHAR(15),
    owner_email VARCHAR(100),
    owner_tax_id VARCHAR(20),       -- TRANSITIVE: via owner_id
    tax_zone VARCHAR(50),           -- TRANSITIVE: via owner_id → owner_tax_id
    tax_rate NUMERIC(5,2),          -- TRANSITIVE: via owner_id → owner_tax_id
    builder_id INT,
    builder_name VARCHAR(150),
    builder_registration VARCHAR(50), -- TRANSITIVE: via builder_id
    regulatory_authority VARCHAR(100), -- TRANSITIVE: via builder_id → builder_registration
    locality_id INT,
    locality_name VARCHAR(100),
    pin_code VARCHAR(10),           -- TRANSITIVE: via locality_id
    post_office VARCHAR(100),       -- TRANSITIVE: via locality_id → pin_code
    delivery_zone VARCHAR(50),      -- TRANSITIVE: via locality_id → pin_code
    city VARCHAR(50),
    state VARCHAR(50),
    amenity_package_id INT,
    gym_type VARCHAR(50),           -- TRANSITIVE: via amenity_package_id
    pool_type VARCHAR(50),          -- TRANSITIVE: via amenity_package_id
    security_level VARCHAR(50),     -- TRANSITIVE: via amenity_package_id
    parking_slots INT,
    maintenance_per_month NUMERIC(10,2),
    power_backup BOOLEAN,
    water_supply VARCHAR(50)
);

INSERT INTO real_estate_properties_not_3nf VALUES
(9001, 'Prestige Lakeside Habitat', 'Apartment', 2500, 2020, '2025-01-15', 18500000.00, 'Available',
 4001, 'Rakesh Mehta', '9876543210', 'rakesh@email.com', 'TXN001',
 'Zone A - Premium', 1.25, 5001, 'Prestige Group', 'REG12345',
 'Karnataka RERA', 6001, 'Varthur', '560087', 'Varthur PO', 'East Zone',
 'Bangalore', 'Karnataka', 7001, 'Premium Gym with Trainer', 'Olympic Size Pool',
 '24x7 Security with CCTV', 2, 5000.00, TRUE, 'Corporation + Borewell'),

(9002, 'DLF Garden City', 'Villa', 4000, 2019, '2025-01-16', 35000000.00, 'Available',
 4002, 'Priya Sharma', '9876543211', 'priya@email.com', 'TXN002',
 'Zone B - Luxury', 1.50, 5002, 'DLF Limited', 'REG67890',
 'Haryana RERA', 6002, 'Gurgaon Sector 91', '122505', 'Gurgaon Sector 91 PO', 'South Zone',
 'Gurgaon', 'Haryana', 7002, 'Standard Gym', 'Medium Pool',
 'Gated Community Security', 3, 8000.00, TRUE, 'Corporation'),

(9003, 'Prestige Tech Park Apartments', 'Apartment', 1800, 2021, '2025-01-17', 12000000.00, 'Sold',
 4001, 'Rakesh Mehta', '9876543210', 'rakesh@email.com', 'TXN001',
 'Zone A - Premium', 1.25, 5001, 'Prestige Group', 'REG12345',
 'Karnataka RERA', 6003, 'Marathahalli', '560037', 'Marathahalli PO', 'Central Zone',
 'Bangalore', 'Karnataka', 7003, 'Basic Gym', 'No Pool',
 'Standard Security', 1, 3000.00, FALSE, 'Corporation');

SELECT * FROM real_estate_properties_not_3nf;

-- ✅ SOLUTION: Convert to 3NF with complete decomposition
CREATE TABLE tax_zones_3nf (
    owner_tax_id VARCHAR(20) PRIMARY KEY,
    tax_zone VARCHAR(50),
    tax_rate NUMERIC(5,2)
);

CREATE TABLE property_owners_3nf (
    owner_id INT PRIMARY KEY,
    owner_name VARCHAR(100),
    owner_phone VARCHAR(15),
    owner_email VARCHAR(100),
    owner_tax_id VARCHAR(20),
    FOREIGN KEY (owner_tax_id) REFERENCES tax_zones_3nf(owner_tax_id)
);

CREATE TABLE regulatory_authorities_3nf (
    builder_registration VARCHAR(50) PRIMARY KEY,
    regulatory_authority VARCHAR(100)
);

CREATE TABLE builders_3nf (
    builder_id INT PRIMARY KEY,
    builder_name VARCHAR(150),
    builder_registration VARCHAR(50),
    FOREIGN KEY (builder_registration) REFERENCES regulatory_authorities_3nf(builder_registration)
);

CREATE TABLE pin_codes_3nf (
    pin_code VARCHAR(10) PRIMARY KEY,
    post_office VARCHAR(100),
    delivery_zone VARCHAR(50)
);

CREATE TABLE localities_3nf (
    locality_id INT PRIMARY KEY,
    locality_name VARCHAR(100),
    pin_code VARCHAR(10),
    city VARCHAR(50),
    state VARCHAR(50),
    FOREIGN KEY (pin_code) REFERENCES pin_codes_3nf(pin_code)
);

CREATE TABLE amenity_packages_3nf (
    amenity_package_id INT PRIMARY KEY,
    gym_type VARCHAR(50),
    pool_type VARCHAR(50),
    security_level VARCHAR(50)
);

CREATE TABLE properties_real_estate_3nf (
    property_id INT PRIMARY KEY,
    property_name VARCHAR(200),
    property_type VARCHAR(50),
    total_area_sqft INT,
    construction_year INT,
    listing_date DATE,
    listing_price NUMERIC(15,2),
    property_status VARCHAR(20),
    owner_id INT,
    builder_id INT,
    locality_id INT,
    amenity_package_id INT,
    parking_slots INT,
    maintenance_per_month NUMERIC(10,2),
    power_backup BOOLEAN,
    water_supply VARCHAR(50),
    FOREIGN KEY (owner_id) REFERENCES property_owners_3nf(owner_id),
    FOREIGN KEY (builder_id) REFERENCES builders_3nf(builder_id),
    FOREIGN KEY (locality_id) REFERENCES localities_3nf(locality_id),
    FOREIGN KEY (amenity_package_id) REFERENCES amenity_packages_3nf(amenity_package_id)
);

-- Insert all normalized data
INSERT INTO tax_zones_3nf VALUES
('TXN001', 'Zone A - Premium', 1.25),
('TXN002', 'Zone B - Luxury', 1.50);

INSERT INTO property_owners_3nf VALUES
(4001, 'Rakesh Mehta', '9876543210', 'rakesh@email.com', 'TXN001'),
(4002, 'Priya Sharma', '9876543211', 'priya@email.com', 'TXN002');

INSERT INTO regulatory_authorities_3nf VALUES
('REG12345', 'Karnataka RERA'),
('REG67890', 'Haryana RERA');

INSERT INTO builders_3nf VALUES
(5001, 'Prestige Group', 'REG12345'),
(5002, 'DLF Limited', 'REG67890');

INSERT INTO pin_codes_3nf VALUES
('560087', 'Varthur PO', 'East Zone'),
('122505', 'Gurgaon Sector 91 PO', 'South Zone'),
('560037', 'Marathahalli PO', 'Central Zone');

INSERT INTO localities_3nf VALUES
(6001, 'Varthur', '560087', 'Bangalore', 'Karnataka'),
(6002, 'Gurgaon Sector 91', '122505', 'Gurgaon', 'Haryana'),
(6003, 'Marathahalli', '560037', 'Bangalore', 'Karnataka');

INSERT INTO amenity_packages_3nf VALUES
(7001, 'Premium Gym with Trainer', 'Olympic Size Pool', '24x7 Security with CCTV'),
(7002, 'Standard Gym', 'Medium Pool', 'Gated Community Security'),
(7003, 'Basic Gym', 'No Pool', 'Standard Security');

INSERT INTO properties_real_estate_3nf VALUES
(9001, 'Prestige Lakeside Habitat', 'Apartment', 2500, 2020, '2025-01-15', 18500000.00, 'Available',
 4001, 5001, 6001, 7001, 2, 5000.00, TRUE, 'Corporation + Borewell'),
(9002, 'DLF Garden City', 'Villa', 4000, 2019, '2025-01-16', 35000000.00, 'Available',
 4002, 5002, 6002, 7002, 3, 8000.00, TRUE, 'Corporation'),
(9003, 'Prestige Tech Park Apartments', 'Apartment', 1800, 2021, '2025-01-17', 12000000.00, 'Sold',
 4001, 5001, 6003, 7003, 1, 3000.00, FALSE, 'Corporation');

-- ULTRA MEGA QUERY: Complete property listing with all details
SELECT 
    p.property_id,
    p.property_name,
    p.property_type,
    p.total_area_sqft,
    p.construction_year,
    p.listing_price,
    p.property_status,
    po.owner_name,
    po.owner_phone,
    tz.tax_zone,
    tz.tax_rate,
    b.builder_name,
    ra.regulatory_authority,
    l.locality_name,
    l.city,
    l.state,
    pc.pin_code,
    pc.post_office,
    pc.delivery_zone,
    ap.gym_type,
    ap.pool_type,
    ap.security_level,
    p.parking_slots,
    p.maintenance_per_month,
    p.power_backup,
    p.water_supply
FROM properties_real_estate_3nf p
JOIN property_owners_3nf po ON p.owner_id = po.owner_id
JOIN tax_zones_3nf tz ON po.owner_tax_id = tz.owner_tax_id
JOIN builders_3nf b ON p.builder_id = b.builder_id
JOIN regulatory_authorities_3nf ra ON b.builder_registration = ra.builder_registration
JOIN localities_3nf l ON p.locality_id = l.locality_id
JOIN pin_codes_3nf pc ON l.pin_code = pc.pin_code
JOIN amenity_packages_3nf ap ON p.amenity_package_id = ap.amenity_package_id;

-- Analytics: Locality-wise property analysis
SELECT 
    l.locality_name,
    l.city,
    COUNT(p.property_id) as total_properties,
    AVG(p.listing_price) as avg_price,
    AVG(p.total_area_sqft) as avg_area,
    AVG(p.maintenance_per_month) as avg_maintenance,
    COUNT(CASE WHEN p.property_status = 'Available' THEN 1 END) as available_count
FROM properties_real_estate_3nf p
JOIN localities_3nf l ON p.locality_id = l.locality_id
GROUP BY l.locality_name, l.city
ORDER BY avg_price DESC;

-- Analytics: Builder performance report
SELECT 
    b.builder_name,
    ra.regulatory_authority,
    COUNT(p.property_id) as total_projects,
    AVG(p.listing_price) as avg_property_price,
    SUM(CASE WHEN p.property_status = 'Sold' THEN 1 ELSE 0 END) as sold_count,
    STRING_AGG(DISTINCT l.city, ', ') as operating_cities
FROM builders_3nf b
JOIN regulatory_authorities_3nf ra ON b.builder_registration = ra.builder_registration
LEFT JOIN properties_real_estate_3nf p ON b.builder_id = p.builder_id
LEFT JOIN localities_3nf l ON p.locality_id = l.locality_id
GROUP BY b.builder_name, ra.regulatory_authority;



-- ✅ Benefits of 3NF:

		-- Eliminates ALL transitive dependencies
		-- Minimizes data redundancy to the maximum extent
		-- Prevents update anomalies completely for normalized attributes
		-- Enables independent management of all entity types
		-- Optimal for OLTP (Online Transaction Processing) systems
		-- Easier to maintain data integrity
		-- Reduces storage requirements significantly







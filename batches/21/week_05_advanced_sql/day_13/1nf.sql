-- FIRST NORMAL FORM (1NF)
		-- A table is in First Normal Form (1NF) if:
				-- Each column contains atomic (indivisible) values
				-- Each column contains values of a single data type
				-- Each column has a unique name
				-- The order of rows and columns doesn't matter
				-- No repeating groups or arrays in a single column

		-- ✅ Rules:
				-- No multi-valued attributes (no comma-separated values)
				-- No repeating groups (no column1, column2, column3 for same attribute)
				-- Each cell should contain only one value

-- ❌ NOT in 1NF: Multiple phone numbers in one column
CREATE TABLE students_not_1nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    phone_numbers VARCHAR(200),  -- VIOLATION: Contains multiple values
    subjects VARCHAR(200)         -- VIOLATION: Comma-separated subjects
);

INSERT INTO students_not_1nf VALUES
(1, 'Rahul Sharma', '9876543210, 9876543211, 9876543212', 'SQL, Python, Java'),
(2, 'Priya Patel', '9988776655', 'Data Analytics, Excel'),
(3, 'Amit Kumar', '9123456789, 9123456790', 'SQL');

SELECT * FROM students_not_1nf;

-- ✅ SOLUTION: Convert to 1NF
-- Create separate table for phone numbers
CREATE TABLE students_1nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100)
);

CREATE TABLE student_phones_1nf (
    student_id INT,
    phone_number VARCHAR(15),
    PRIMARY KEY (student_id, phone_number),
    FOREIGN KEY (student_id) REFERENCES students_1nf(student_id)
);

CREATE TABLE student_subjects_1nf (
    student_id INT,
    subject_name VARCHAR(50),
    PRIMARY KEY (student_id, subject_name),
    FOREIGN KEY (student_id) REFERENCES students_1nf(student_id)
);

-- Insert data in 1NF
INSERT INTO students_1nf VALUES
(1, 'Rahul Sharma'),
(2, 'Priya Patel'),
(3, 'Amit Kumar');

INSERT INTO student_phones_1nf VALUES
(1, '9876543210'),
(1, '9876543211'),
(1, '9876543212'),
(2, '9988776655'),
(3, '9123456789'),
(3, '9123456790');

INSERT INTO student_subjects_1nf VALUES
(1, 'SQL'),
(1, 'Python'),
(1, 'Java'),
(2, 'Data Analytics'),
(2, 'Excel'),
(3, 'SQL');

select * from students_1nf;
select * from student_phones_1nf;
select * from student_subjects_1nf;

-- Query to retrieve student with all phones and subjects
SELECT 
    s.student_id,
    s.student_name,
    STRING_AGG(DISTINCT sp.phone_number, ', ') as phone_numbers,
    STRING_AGG(DISTINCT ss.subject_name, ', ') as subjects
FROM students_1nf s
LEFT JOIN student_phones_1nf sp ON s.student_id = sp.student_id
LEFT JOIN student_subjects_1nf ss ON s.student_id = ss.student_id
GROUP BY s.student_id, s.student_name;


-- ❌ NOT in 1NF: Complex nested data
CREATE TABLE patient_treatments_not_1nf (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    age INT,
    doctors VARCHAR(300),  -- VIOLATION: Multiple doctors
    diagnoses TEXT,        -- VIOLATION: Multiple diagnoses
    medicines TEXT,        -- VIOLATION: Multiple medicines with dosages
    allergies VARCHAR(200), -- VIOLATION: Multiple allergies
    blood_tests_results TEXT -- VIOLATION: Multiple test results
);

INSERT INTO patient_treatments_not_1nf VALUES
(2001, 'Ramesh Singh', 55, 'Dr.Mehta(Cardiology)|Dr.Verma(General)', 
 'High BP|Diabetes Type-2|High Cholesterol', 
 'Amlodipine:5mg daily|Metformin:500mg twice|Atorvastatin:10mg nightly',
 'Penicillin|Sulfa Drugs',
 'HbA1c:7.2%|Cholesterol:240mg/dL|BP:140/90');

SELECT * FROM patient_treatments_not_1nf;

-- ✅ SOLUTION: Convert to 1NF with proper structure
CREATE TABLE patients_1nf (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    age INT
);

CREATE TABLE doctors_1nf (
    doctor_id SERIAL PRIMARY KEY,
    doctor_name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE patient_doctors_1nf (
    patient_id INT,
    doctor_id INT,
    PRIMARY KEY (patient_id, doctor_id),
    FOREIGN KEY (patient_id) REFERENCES patients_1nf(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors_1nf(doctor_id)
);

CREATE TABLE diagnoses_1nf (
    diagnosis_id SERIAL PRIMARY KEY,
    patient_id INT,
    diagnosis_name VARCHAR(150),
    diagnosed_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients_1nf(patient_id)
);

CREATE TABLE prescriptions_1nf (
    prescription_id SERIAL PRIMARY KEY,
    patient_id INT,
    medicine_name VARCHAR(100),
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    FOREIGN KEY (patient_id) REFERENCES patients_1nf(patient_id)
);

CREATE TABLE patient_allergies_1nf (
    patient_id INT,
    allergy_name VARCHAR(100),
    PRIMARY KEY (patient_id, allergy_name),
    FOREIGN KEY (patient_id) REFERENCES patients_1nf(patient_id)
);

CREATE TABLE blood_tests_1nf (
    test_id SERIAL PRIMARY KEY,
    patient_id INT,
    test_name VARCHAR(100),
    test_result VARCHAR(100),
    test_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients_1nf(patient_id)
);

-- Insert normalized data
INSERT INTO patients_1nf VALUES (2001, 'Ramesh Singh', 55);

INSERT INTO doctors_1nf (doctor_name, specialization) VALUES
('Dr. Mehta', 'Cardiology'),
('Dr. Verma', 'General');

INSERT INTO patient_doctors_1nf VALUES
(2001, 1),
(2001, 2);

INSERT INTO diagnoses_1nf (patient_id, diagnosis_name, diagnosed_date) VALUES
(2001, 'High BP', '2025-01-10'),
(2001, 'Diabetes Type-2', '2025-01-10'),
(2001, 'High Cholesterol', '2025-01-10');

INSERT INTO prescriptions_1nf (patient_id, medicine_name, dosage, frequency) VALUES
(2001, 'Amlodipine', '5mg', 'daily'),
(2001, 'Metformin', '500mg', 'twice daily'),
(2001, 'Atorvastatin', '10mg', 'nightly');

INSERT INTO patient_allergies_1nf VALUES
(2001, 'Penicillin'),
(2001, 'Sulfa Drugs');

INSERT INTO blood_tests_1nf (patient_id, test_name, test_result, test_date) VALUES
(2001, 'HbA1c', '7.2%', '2025-01-10'),
(2001, 'Cholesterol', '240 mg/dL', '2025-01-10'),
(2001, 'Blood Pressure', '140/90', '2025-01-10');

-- Complex query: Patient complete medical profile
SELECT 
    p.patient_id,
    p.patient_name,
    p.age,
    STRING_AGG(DISTINCT d.doctor_name || ' (' || d.specialization || ')', ', ') as doctors,
    STRING_AGG(DISTINCT diag.diagnosis_name, ', ') as diagnoses,
    STRING_AGG(DISTINCT pr.medicine_name || ': ' || pr.dosage || ' ' || pr.frequency, ', ') as prescriptions,
    STRING_AGG(DISTINCT pa.allergy_name, ', ') as allergies,
    STRING_AGG(DISTINCT bt.test_name || ': ' || bt.test_result, ', ') as test_results
FROM patients_1nf p
LEFT JOIN patient_doctors_1nf pd ON p.patient_id = pd.patient_id
LEFT JOIN doctors_1nf d ON pd.doctor_id = d.doctor_id
LEFT JOIN diagnoses_1nf diag ON p.patient_id = diag.patient_id
LEFT JOIN prescriptions_1nf pr ON p.patient_id = pr.patient_id
LEFT JOIN patient_allergies_1nf pa ON p.patient_id = pa.patient_id
LEFT JOIN blood_tests_1nf bt ON p.patient_id = bt.patient_id
WHERE p.patient_id = 2001
GROUP BY p.patient_id, p.patient_name, p.age;

		-- ✅ Benefits of 1NF:

			-- 	Eliminates repeating groups
			-- 	Atomic values enable precise querying
			-- 	Better data integrity
			-- 	Supports efficient indexing
			-- 	Enables proper JOIN operations













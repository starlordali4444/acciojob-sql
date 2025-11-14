-- SECOND NORMAL FORM (2NF)
		-- A table is in Second Normal Form (2NF) if:
				-- It is already in 1NF
				-- It has NO partial dependencies (all non-key attributes must depend on the ENTIRE primary key, not just part of it)

		-- ✅ Rules:

				-- 	Applies only to tables with composite primary keys (multiple columns as PK)
				-- 	Every non-key column must depend on the complete primary key, not just a portion of it
				-- 	If a table has a single-column primary key, it's automatically in 2NF (if it's in 1NF)
		
		-- 🎯 Key Concept:
				-- 	Partial Dependency = When a non-key attribute depends on only PART of a composite key


-- ❌ NOT in 2NF: Has partial dependencies
-- Composite Key: (student_id, course_id)
CREATE TABLE student_grades_not_2nf (
    student_id INT,
    course_id INT,
    student_name VARCHAR(100),      -- PARTIAL DEPENDENCY: Depends only on student_id
    student_email VARCHAR(100),     -- PARTIAL DEPENDENCY: Depends only on student_id
    course_name VARCHAR(100),       -- PARTIAL DEPENDENCY: Depends only on course_id
    instructor_name VARCHAR(100),   -- PARTIAL DEPENDENCY: Depends only on course_id
    grade CHAR(2),                  -- FULL DEPENDENCY: Depends on both student_id AND course_id
    semester VARCHAR(20),           -- FULL DEPENDENCY: Depends on both
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_grades_not_2nf VALUES
(101, 201, 'Rahul Sharma', 'rahul@email.com', 'SQL Fundamentals', 'Siraj Ali', 'A', 'Spring 2025'),
(101, 202, 'Rahul Sharma', 'rahul@email.com', 'Python Programming', 'Priya Singh', 'B+', 'Spring 2025'),
(102, 201, 'Priya Patel', 'priya@email.com', 'SQL Fundamentals', 'Siraj Ali', 'A+', 'Spring 2025'),
(103, 203, 'Amit Kumar', 'amit@email.com', 'Data Analytics', 'Rajesh Verma', 'B', 'Spring 2025');

SELECT * FROM student_grades_not_2nf;

-- ❌ PROBLEMS with this design:
-- 1. Student name and email repeat for each course enrollment
-- 2. Course name and instructor repeat for each student enrollment
-- 3. Update Anomaly: If course instructor changes, must update all enrolled students
-- 4. Insertion Anomaly: Cannot add new course without student enrollment

-- ✅ SOLUTION: Convert to 2NF by removing partial dependencies
CREATE TABLE students_2nf (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    student_email VARCHAR(100)
);

CREATE TABLE courses_2nf (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    instructor_name VARCHAR(100)
);

CREATE TABLE enrollments_2nf (
    student_id INT,
    course_id INT,
    grade CHAR(2),
    semester VARCHAR(20),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students_2nf(student_id),
    FOREIGN KEY (course_id) REFERENCES courses_2nf(course_id)
);

-- Insert normalized data
INSERT INTO students_2nf VALUES
(101, 'Rahul Sharma', 'rahul@email.com'),
(102, 'Priya Patel', 'priya@email.com'),
(103, 'Amit Kumar', 'amit@email.com');

INSERT INTO courses_2nf VALUES
(201, 'SQL Fundamentals', 'Siraj Ali'),
(202, 'Python Programming', 'Priya Singh'),
(203, 'Data Analytics', 'Rajesh Verma');

INSERT INTO enrollments_2nf VALUES
(101, 201, 'A', 'Spring 2025'),
(101, 202, 'B+', 'Spring 2025'),
(102, 201, 'A+', 'Spring 2025'),
(103, 203, 'B', 'Spring 2025');

-- Query: Student report card
SELECT 
    s.student_id,
    s.student_name,
    s.student_email,
    c.course_name,
    c.instructor_name,
    e.grade,
    e.semester
FROM students_2nf s
JOIN enrollments_2nf e ON s.student_id = e.student_id
JOIN courses_2nf c ON e.course_id = c.course_id
WHERE s.student_id = 101
ORDER BY c.course_name;

-- Benefits: Now we can add new courses without students!
INSERT INTO courses_2nf VALUES
(204, 'Machine Learning', 'Dr. Sharma');

-- ✅ Benefits of 2NF:
		-- Eliminates partial dependencies
		-- Reduces data redundancy dramatically
		-- Prevents update anomalies on partial key attributes
		-- Allows independent management of entities
		-- Improved query performance through better indexing


-- BOYCE-CODD NORMAL FORM (BCNF)

	-- A table is in Boyce-Codd Normal Form (BCNF) if:
	
			-- It is already in 3NF
			-- For every functional dependency X → Y, X must be a super key (candidate key)
	
	-- ✅ Rules:
	
			-- BCNF is a stricter version of 3NF
			-- Eliminates anomalies that can exist even in 3NF
			-- Every determinant must be a candidate key
			-- No non-trivial functional dependencies exist where the left side is not a super key
	
	-- 🎯 Key Concept:
		-- BCNF addresses cases where: A table is in 3NF but still has anomalies due to overlapping candidate keys


-- ❌ NOT in BCNF (but in 3NF): Overlapping candidate keys
-- Candidate Keys: (student_id, course_id) OR (student_id, instructor_id)
-- Functional Dependencies:
-- - student_id, course_id → instructor_id (valid for 3NF)
-- - instructor_id → course_id (VIOLATION: instructor_id is not a super key)
-- Problem: Each instructor teaches only ONE course, creating dependency

CREATE TABLE course_enrollments_not_bcnf (
    student_id INT,
    course_id INT,
    instructor_id INT,
    enrollment_date DATE,
    PRIMARY KEY (student_id, course_id)
    -- Constraint: Each instructor teaches only ONE specific course
);

INSERT INTO course_enrollments_not_bcnf VALUES
(101, 201, 301, '2025-01-10'),  -- Student 101, Course 201, Instructor 301
(102, 201, 301, '2025-01-10'),  -- Student 102, Course 201, Instructor 301 (same course, same instructor)
(103, 202, 302, '2025-01-11'),  -- Student 103, Course 202, Instructor 302
(101, 202, 302, '2025-01-11');  -- Student 101, Course 202, Instructor 302

SELECT * FROM course_enrollments_not_bcnf;

-- ❌ PROBLEM: What if we want to record that Instructor 303 teaches Course 203, 
-- but no student has enrolled yet? We can't! (Insertion Anomaly)

-- ❌ PROBLEM: If all students drop Course 201, we lose the information 
-- that Instructor 301 teaches Course 201 (Deletion Anomaly)

-- ✅ SOLUTION: Convert to BCNF
-- Separate the problematic functional dependency instructor_id → course_id
CREATE TABLE instructor_courses_bcnf (
    instructor_id INT PRIMARY KEY,
    course_id INT,
    course_name VARCHAR(100)
);

CREATE TABLE student_enrollments_bcnf (
    student_id INT,
    instructor_id INT,
    enrollment_date DATE,
    PRIMARY KEY (student_id, instructor_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor_courses_bcnf(instructor_id)
);

INSERT INTO instructor_courses_bcnf VALUES
(301, 201, 'Data Structures'),
(302, 202, 'Database Systems'),
(303, 203, 'Web Development');  -- Can add even without student enrollments!

INSERT INTO student_enrollments_bcnf VALUES
(101, 301, '2025-01-10'),
(102, 301, '2025-01-10'),
(103, 302, '2025-01-11'),
(101, 302, '2025-01-11');

-- Query: Get enrollments with course details
SELECT 
    se.student_id,
    ic.course_id,
    ic.course_name,
    ic.instructor_id,
    se.enrollment_date
FROM student_enrollments_bcnf se
JOIN instructor_courses_bcnf ic ON se.instructor_id = ic.instructor_id;




-- ❌ NOT in BCNF: Skill level depends on skill, not on employee
-- Candidate Keys: (emp_id, project_id, skill)
-- Functional Dependency: skill → skill_category (VIOLATION: skill is not a super key)
CREATE TABLE employee_project_skills_not_bcnf (
    emp_id INT,
    project_id INT,
    skill VARCHAR(50),
    skill_category VARCHAR(50),  -- Depends only on skill
    hours_worked INT,
    PRIMARY KEY (emp_id, project_id, skill)
);

INSERT INTO employee_project_skills_not_bcnf VALUES
(101, 501, 'PostgreSQL', 'Database', 40),
(101, 502, 'Python', 'Programming', 60),
(102, 501, 'PostgreSQL', 'Database', 50),  -- Skill category repeated
(103, 503, 'React', 'Frontend', 45);

SELECT * FROM employee_project_skills_not_bcnf;

-- ✅ SOLUTION: Convert to BCNF
CREATE TABLE skills_catalog_bcnf (
    skill VARCHAR(50) PRIMARY KEY,
    skill_category VARCHAR(50)
);

CREATE TABLE employee_project_work_bcnf (
    emp_id INT,
    project_id INT,
    skill VARCHAR(50),
    hours_worked INT,
    PRIMARY KEY (emp_id, project_id, skill),
    FOREIGN KEY (skill) REFERENCES skills_catalog_bcnf(skill)
);

INSERT INTO skills_catalog_bcnf VALUES
('PostgreSQL', 'Database'),
('Python', 'Programming'),
('React', 'Frontend');

INSERT INTO employee_project_work_bcnf VALUES
(101, 501, 'PostgreSQL', 40),
(101, 502, 'Python', 60),
(102, 501, 'PostgreSQL', 50),
(103, 503, 'React', 45);

-- Query with skill category
SELECT 
    epw.emp_id,
    epw.project_id,
    epw.skill,
    sc.skill_category,
    epw.hours_worked
FROM employee_project_work_bcnf epw
JOIN skills_catalog_bcnf sc ON epw.skill = sc.skill;

INSERT INTO allocation (activity_id, worker_id, instance_id, allocated_hours)
VALUES (8, 7, 3, 50), (7, 9, 2, 50);  --



INSERT INTO course (course_code) VALUES
('CS101'),
('MA202'),
('PH303');
INSERT INTO course (course_code) VALUES
('IS1200'),
('IV1350'),
('IV1351');



INSERT INTO course_layout (max_students,version_number,course_id,min_students,hp,course_name)
VALUES  (200,1,1,25,7.50,'Computer Science 1'),
(150,2,1,30,7.50,'Computer Science 1'),
(150,1,2,20,7.50,'Computer Science 2'),
(200,2,2,25,7.50,'Computer Science 2 '),
(150,1,6,20,7.50,'Programming for Data Science'),
(200,2,6,30,7.50,'Programming for Data Science');


INSERT INTO course_instance (num_students, study_period, study_year, layout_id) VALUES
(150,'P1',2025,1),
(200,'P2',2025,3),
(180,'P2',2025,2),
(160,'P3',2025,4);

INSERT INTO teaching_activity (activity_name, factor) VALUES
('Lecture', 3.60),
('Lab', 2.40),
('Tutorial', 2.40),
('Seminar', 1.80),
('Others', 1.50);

INSERT INTO planned_activity (activity_id, instance_id, planned_hours) VALUES
(5,2, 40), (6,3, 30), (4,4, 20), (4,1, 25), (5,1, 35);


INSERT INTO person (personal_number, first_name, last_name, phone_no, adress_name, zip, city, country) VALUES
('123456789012', 'Alice', 'Smith', '1234567890', '123 Main St', '12345', 'CityA', 'CountryX'),
('234567890123', 'Bob', 'Johnson', '2345678901', '456 Elm St', '23456', 'CityB', 'CountryY');
INSERT INTO person (personal_number, first_name, last_name, phone_no, adress_name, zip, city, country) VALUES
('345678901234', 'Charlie', 'Brown', '3456789012', '789 Oak St', '34567', 'CityC', 'CountryZ'),
('456789012345', 'Diana', 'Prince', '4567890123', '101 Pine St', '45678', 'CityD', 'CountryW');
INSERT INTO person (personal_number, first_name, last_name, phone_no, adress_name, zip, city, country) VALUES
('567890123456', 'Ethan', 'Hunt', '5678901234', '202 Maple St', '56789', 'CityE', 'CountryV');



INSERT INTO job_title (job_title) 
VALUES ('Professor'), ('Associate Professor'), ('Assistant Professor'), ('Lecturer'), ('Researcher');




INSERT INTO department (department_name) VALUES
('Computer Science'),
('Mathematics'),
('Physics');


INSERT INTO employee (employment_id, email, job_id, department_id, person_id, supervisor_id) 
VALUES 

('EMID500001', 'leilin@uni.com', 2, 4, 1, NULL),

rätt 

('EMID500009', 'kardil@uni.com', 2, 5,5, NULL),
('EMID500010', 'friwol@uni.com', 1, 6, 2, NULL);



--




INSERT INTO skill (skill_name, description) VALUES
('SQL', 'Proficient in SQL database management and queries.'),
('Python', 'Experienced in Python programming for data analysis and web development.'),
('Java', 'Skilled in Java programming for application development.'),
('Project Management', 'Able to manage projects effectively using various methodologies.'),
('Data Analysis', 'Experienced in analyzing data to extract insights and inform decisions.');


INSERT INTO employee_skill (worker_id, skill_id) VALUES
(7, 1), 
(8, 2),  
(9, 3), 
(7, 4),  
(8, 5);  



INSERT INTO salary (start_date, worker_id, salary) VALUES
('2025-01-01', 7, 55000),
('2025-01-01', 8, 72000),
('2025-01-01', 9, 52000);




INSERT INTO allocation_limit (max_allocation) VALUES (4);



INSERT INTO allocation (activity_id, worker_id, instance_id, allocated_hours) VALUES
(6,8,3,25),
(5,9,1,20),
(4,7,4,30);


SELECT ci.instance_id,
       c.hp,
       ci.study_period,
       ci.study_year,
       SUM(pa.planned_hours) AS planned_hours,
       (32 + 0.725 * ci.num_students) AS exam_hours,
       (2 * c.hp + 28 + 0.2 * ci.num_students) AS admin_hours,
       SUM(pa.planned_hours)
         + (32 + 0.725 * ci.num_students)
         + (2 * c.hp + 28 + 0.2 * ci.num_students) AS total_hours
FROM course_instance ci
JOIN course_layout c ON c.layout_id = ci.layout_id
LEFT JOIN planned_activity pa ON pa.instance_id = ci.instance_id
GROUP BY ci.instance_id, c.layout_id,ci.study_period, ci.study_year, ci.num_students, c.hp;

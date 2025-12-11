
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


-- 
INSERT INTO person (personal_number, first_name, last_name, phone_no, adress_name, zip, city, country) VALUES
('6603021312', 'Alice', 'Johnman', '0764563245', '7', '16704', 'Stockholm', 'Sweden'),
('6801022203', 'Bob', 'Larsson', '0896753233', 'Thorildsplan 4', '13404', 'Stockholm', 'Sweden');
INSERT INTO person (personal_number, first_name, last_name, phone_no, adress_name, zip, city, country) VALUES
('760403205478', 'Charlie', 'Pacal', '0984567245', 'Thorildsplan 3', '13256', 'Stockholm', 'Sweden'),
('4564789900', 'Diana', 'Owen', '0704523227', 'Thorildsplan 675', '54678', 'Stockholm', 'Sweden');
INSERT INTO person (personal_number, first_name, last_name, phone_no, adress_name, zip, city, country) VALUES
('8902033453', 'Meredith', 'Grey', '0709544555', 'Thorildsplan 1', '98234', 'Stockholm', 'Sweden');

INSERT INTO course (course_code) VALUES
('TH1111'),
('OP3456'),
('OP4444');
INSERT INTO course (course_code) VALUES
('IS3333'),
('IV1300'),
('IV1357');


INSERT INTO course_layout (max_students,version_number,course_id,min_students,hp,course_name)
VALUES  (200,1,7,25,7.50,'Matematik algebra'),
(150,2,8,30,7.50,'Matematik diskret'),
(150,1,9,20,7.50,'Envariabelanalys'),
(200,2,10,25,7.50,'Flervariabelanalys '),
(150,1,11,20,7.50,'Logik för dataloger'),
(200,2,12,30,7.50,'Digital design');

INSERT INTO course_instance (num_students, study_period, study_year, layout_id) VALUES
(150,'P1',2025,9),
(200,'P2',2025,10),
(180,'P2',2025,11),
(160,'P3',2025,12);


INSERT INTO department (department_name) VALUES
('Svenska'),
('Kemi'),
('Biolgoi');


INSERT INTO employee (employment_id, email, job_id, department_id, person_id, supervisor_id) 
VALUES 

('EMID510201', 'dowen@kth.se', 1, 6, 4, NULL), 
('EMID510211', 'cpacal@kth.se', 2, 6, 9, NULL),
('EMID510221', 'mgrey@kth.se', 3, 6, 10, NULL),
('EMID510231', 'blarsson@kth.se', 4, 5, 11, NULL),
('EMID510241', 'ajohnman@kth.se', 3, 5, 13, NULL),
('EMID510251', 'ehunt@kth.se', 5, 5, 12, NULL)


INSERT INTO salary (start_date, worker_id, salary) VALUES
('2025-01-19', 9, 55000),
('2025-01-01', 24, 72000),
('2025-01-01', 25, 55000),
('2025-01-01', 26, 72000),
('2025-01-01', 27, 55000),
('2025-01-01', 28, 72000),
('2025-01-01', 29, 52000);






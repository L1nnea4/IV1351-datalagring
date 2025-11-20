'**** please note that this is NOT all the queries we run
we did more to see that we could for example calculate the admin and examination hours 
    and to see that the trigger works and also to test to calculate the preparation time for a teacher
    however, we are new to SQL and do not know how to retrieve all the query so this is just a small part 
    of the query we have saved ****'
    'new values inserted'
INSERT INTO course_layout (max_students,version_number,course_id,min_students,hp,course_name)
VALUES (200,12,1,20,15,'Databases');
INSERT INTO course_layout (max_students,version_number,course_id,min_students,hp,course_name)
VALUES (230,12,2,40,15,'Algorithms');
INSERT INTO course (course_code) 
VALUES ('iv1351');
INSERT INTO course(course_code)
VALUES('iv1350');


INSERT INTO course_instance (num_students, study_period, study_year, layout_id)
VALUES (150,'P2',2026,4);



INSERT INTO course_instance (num_students, study_period, study_year, layout_id)
VALUES (190,'P3',2026,3);


INSERT INTO salary (version, worker_id, salary)
VALUES ('2025-01-14',17,50500);


INSERT INTO salary (version, worker_id, salary) 
VALUES('2026-01-18',18,60000);

INSERT INTO person (
    personal_number,
    first_name,
    last_name,
    phone_no,
    adress_name,
    zip,
    city,
    country
) VALUES
('199001011234', 'Linn', 'Andersson', '0701234567', 'Storgatan 12', '12345', 'Stockholm', 'Sweden'),
('198512309876', 'Anna', 'Karlsson', '0709876543', 'Sveavägen 45', '11122', 'Stockholm', 'Sweden'),
('197703152345', 'Erik', 'Johansson', '0734567890', 'Kungsgatan 7', '41111', 'Göteborg', 'Sweden'),
('200205061111', 'Sara', 'Nilsson', '0721112233', 'Västra Hamngatan 3', '22222', 'Malmö', 'Sweden'),
('199912312222', 'Oskar', 'Berg', '0763334444', 'Norrlandsgatan 9', '33333', 'Uppsala', 'Sweden');

INSERT INTO skill (skill_name, description) VALUES
('SQL', 'Proficient in SQL database management and queries.'),
('Python', 'Experienced in Python programming for data analysis and web development.'),
('Java', 'Skilled in Java programming for application development.'),
('Project Management', 'Able to manage projects effectively using various methodologies.'),
('Data Analysis', 'Experienced in analyzing data to extract insights and inform decisions.');





INSERT INTO teaching_activity (activity_name) VALUES
('Lecture'),
('Lab'),
('Seminar'),
('Tutorials'),
('Others');

INSERT INTO activity_factor VALUES (1.0),(1.2),(1.5),(2.0);

INSERT INTO course (course_code) VALUES ('iv1350'), ('iv1351');

INSERT INTO course (course_code) VALUES ('is1200'), ('id1021');

INSERT INTO course_layout (max_students,version_number,course_id,min_students,hp,course_name)
VALUES (230,12,2,40,15,'Algorithms');
INSERT INTO course_layout (max_students,version_number,course_id,min_students,hp,course_name)
VALUES (250,10,3,20,15,'Algorithms'),(100,9,3,10,7.5,'Algorithms'),(300,4,2,40,7.5,'Algorithms');

INSERT INTO department (department_name, manager_id) 
VALUES ('Computer Science', 1), ('Mathematics', 2), ('Physics', 3);

INSERT INTO job_title (job_title) 
VALUES ('Professor'), ('Associate Professor'), ('Assistant Professor'), ('Lecturer'), ('Researcher');

INSERT INTO course_instance (num_students, study_period, study_year, layout_id)
VALUES (150,'P2',2026,2);


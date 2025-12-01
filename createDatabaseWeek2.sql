SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- ENUM TYPE
CREATE TYPE study_period_enum AS ENUM ('P1','P2','P3','P4');

-- FUNCTION: allocation limit check
CREATE FUNCTION check_allocation_limit() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE 
    current_allocation INT;
    v_max_allocation INT;
    v_study_period study_period_enum;
    v_study_year INT;
BEGIN
    SELECT ci.study_period, ci.study_year
    INTO v_study_period, v_study_year
    FROM course_instance ci
    WHERE ci.instance_id = NEW.instance_id;

    SELECT COUNT(DISTINCT a.instance_id)
    INTO current_allocation
    FROM allocation a
    JOIN course_instance ci ON a.instance_id = ci.instance_id
    WHERE a.worker_id = NEW.worker_id
      AND ci.study_period = v_study_period
      AND ci.study_year = v_study_year;

    SELECT max_allocation INTO v_max_allocation
    FROM allocation_limit
    LIMIT 1;

    IF current_allocation + 1 > v_max_allocation THEN
        RAISE EXCEPTION 'Allocation limit exceeded for worker_id % in study_period % and study_year %',
            NEW.worker_id, v_study_period, v_study_year;
    END IF;

    RETURN NEW;
END;
$$;

-- TABLES ==================================

CREATE TABLE course (
    course_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_code CHAR(6) NOT NULL UNIQUE
);

CREATE TABLE course_layout (
    layout_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    max_students INTEGER NOT NULL,
    version_number INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    min_students INTEGER NOT NULL,
    hp NUMERIC(4,2) NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    CONSTRAINT chk_min_max_students CHECK (min_students <= max_students),
    CONSTRAINT chk_min_student CHECK (min_students > 0),
    UNIQUE(course_id, version_number)
);

CREATE TABLE course_instance (
    instance_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    num_students INTEGER NOT NULL,
    study_period study_period_enum NOT NULL,
    study_year INTEGER NOT NULL,
    layout_id INTEGER NOT NULL,
    UNIQUE(layout_id, study_period, study_year)
);

CREATE TABLE teaching_activity (
    activity_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    activity_name VARCHAR(100) NOT NULL,
    factor NUMERIC(4,2) NOT NULL
);

CREATE TABLE planned_activity (
    activity_id INTEGER NOT NULL,
    instance_id INTEGER NOT NULL,
    planned_hours INTEGER NOT NULL,
    PRIMARY KEY(activity_id, instance_id)
);

CREATE TABLE person (
    person_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    personal_number VARCHAR(12) NOT NULL UNIQUE,
    first_name CHAR(50) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_no CHAR(10) UNIQUE,
    adress_name VARCHAR(50),
    zip CHAR(5),
    city VARCHAR(50),
    country VARCHAR(100)
);

CREATE TABLE job_title (
    job_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL
);

CREATE TABLE department (
    department_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    manager_id INTEGER
);

CREATE TABLE employee (
    worker_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employment_id CHAR(10) NOT NULL UNIQUE,
    email VARCHAR(200) NOT NULL,
    job_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    person_id INTEGER NOT NULL UNIQUE,
    supervisor_id INTEGER
);

CREATE TABLE skill (
    skill_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    skill_name VARCHAR(30),
    description TEXT
);

CREATE TABLE employee_skill (
    worker_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    PRIMARY KEY(worker_id, skill_id)
);

CREATE TABLE salary (
    start_date DATE NOT NULL,
    worker_id INTEGER NOT NULL,
    salary INTEGER NOT NULL,
    PRIMARY KEY(start_date, worker_id)
);

CREATE TABLE allocation_limit (
    max_allocation INTEGER NOT NULL CHECK (max_allocation > 0)
);

CREATE TABLE allocation (
    activity_id INTEGER NOT NULL,
    worker_id INTEGER NOT NULL,
    instance_id INTEGER NOT NULL,
    allocated_hours INTEGER,
    PRIMARY KEY(activity_id, worker_id, instance_id)
);

-- FOREIGN KEYS ================================

ALTER TABLE course_layout
    ADD FOREIGN KEY (course_id) REFERENCES course(course_id);

ALTER TABLE course_instance
    ADD FOREIGN KEY (layout_id) REFERENCES course_layout(layout_id);

ALTER TABLE planned_activity
    ADD FOREIGN KEY (activity_id) REFERENCES teaching_activity(activity_id) ON DELETE CASCADE;

ALTER TABLE planned_activity
    ADD FOREIGN KEY (instance_id) REFERENCES course_instance(instance_id) ON DELETE CASCADE;

ALTER TABLE allocation
    ADD FOREIGN KEY (activity_id, instance_id) REFERENCES planned_activity(activity_id, instance_id) ON DELETE CASCADE;

ALTER TABLE allocation
    ADD FOREIGN KEY (worker_id) REFERENCES employee(worker_id) ON DELETE CASCADE;

ALTER TABLE employee
    ADD FOREIGN KEY (job_id) REFERENCES job_title(job_id);

ALTER TABLE employee
    ADD FOREIGN KEY (department_id) REFERENCES department(department_id);

ALTER TABLE employee
    ADD FOREIGN KEY (person_id) REFERENCES person(person_id);

ALTER TABLE employee
    ADD FOREIGN KEY (supervisor_id) REFERENCES employee(worker_id) ON DELETE SET NULL;

ALTER TABLE department
    ADD FOREIGN KEY (manager_id) REFERENCES employee(worker_id);

ALTER TABLE employee_skill
    ADD FOREIGN KEY (worker_id) REFERENCES employee(worker_id) ON DELETE CASCADE;

ALTER TABLE employee_skill
    ADD FOREIGN KEY (skill_id) REFERENCES skill(skill_id) ON DELETE CASCADE;

ALTER TABLE salary
    ADD FOREIGN KEY (worker_id) REFERENCES employee(worker_id) ON DELETE CASCADE;

-- TRIGGER ======================================

CREATE TRIGGER allocation_violation
BEFORE INSERT OR UPDATE ON allocation
FOR EACH ROW EXECUTE FUNCTION check_allocation_limit();

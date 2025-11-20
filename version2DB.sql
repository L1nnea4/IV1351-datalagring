DROP TABLE IF EXISTS "activity_factor" CASCADE;
CREATE TABLE "activity_factor" (
 "factor" DECIMAL(4,2) NOT NULL
);


DROP TABLE IF EXISTS "course" CASCADE ;
CREATE TABLE "course" (
 "course_id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
 "course_code" CHAR(6) NOT NULL UNIQUE
);


DROP TABLE IF EXISTS "course_layout" CASCADE ;
CREATE TABLE "course_layout" (
 "layout_id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
 "max_students" INT NOT NULL,
 "version_number" INT NOT NULL,
 "course_id" INT NOT NULL,
 "min_students" INT NOT NULL,
 "hp" DECIMAL(4,2) NOT NULL,
 "course_name" VARCHAR(100) NOT NULL,

 FOREIGN KEY ("course_id") REFERENCES "course" ("course_id")
);

ALTER TABLE course_layout ADD CONSTRAINT UQ_course_version UNIQUE (course_id, version_number);
ALTER TABLE course_layout ADD CONSTRAINT CHK_min_max_students CHECK  (min_students <= max_students);
ALTER TABLE course_layout ADD CONSTRAINT CHK_min_student CHECK (min_students > 0);



DROP TABLE IF EXISTS "department" CASCADE ;
CREATE TABLE "department" (
 "department_id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
 "department_name" VARCHAR(50) NOT NULL,
 "manager_id" INT NOT NULL
);


DROP TABLE IF EXISTS "job_title" CASCADE ;
CREATE TABLE "job_title" (
 "job_id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
 "job_title" VARCHAR(100) NOT NULL
);


DROP TABLE IF EXISTS "person" CASCADE ;
CREATE TABLE "person" (
 "person_id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
 "personal_number" VARCHAR(12) NOT NULL UNIQUE,
 "first_name" CHAR(50) NOT NULL,
 "last_name" VARCHAR(100) NOT NULL,
 "phone_no" CHAR(10) UNIQUE,
 "adress_name" VARCHAR(50),
 "zip" CHAR(5),
 "city" VARCHAR(50),
 "country" VARCHAR(100)
);


DROP TABLE IF EXISTS "skill" CASCADE ;
CREATE TABLE "skill" (
 "skill_id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
 "skill_name" VARCHAR(30),
 "description"  TEXT
);


DROP TABLE IF EXISTS "teaching_activity" CASCADE ;
CREATE TABLE "teaching_activity" (
 "activity_id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
 "activity_name" VARCHAR(100) NOT NULL
);

CREATE TYPE study_period_enum AS ENUM ('P1', 'P2', 'P3', 'P4');
DROP TABLE IF EXISTS "course_instance" CASCADE ;
CREATE TABLE "course_instance" (
 "instance_id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
 "num_students" INT NOT NULL,
 "study_period" study_period_enum NOT NULL,
 "study_year" INT NOT NULL,
 "layout_id" INT NOT NULL,

 FOREIGN KEY ("layout_id") REFERENCES "course_layout" ("layout_id")
);
ALTER TABLE course_instance ADD CONSTRAINT UQ_course_instance UNIQUE (layout_id,study_period,study_year);


DROP TABLE IF EXISTS "employee" CASCADE ;
CREATE TABLE "employee" (
 "worker_id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
 "employment_id" CHAR(10) NOT NULL UNIQUE,
 "email" VARCHAR(200) NOT NULL,
 "job_id" INT NOT NULL,
 "department_id" INT NOT NULL,
 "person_id" INT NOT NULL UNIQUE,
 "supervisor_id" INT,

 FOREIGN KEY ("job_id") REFERENCES "job_title" ("job_id") ON DELETE NO ACTION,
 FOREIGN KEY ("department_id") REFERENCES "department" ("department_id") ON DELETE NO ACTION,
 FOREIGN KEY ("person_id") REFERENCES "person" ("person_id") ON DELETE NO ACTION,
 FOREIGN KEY ("supervisor_id") REFERENCES "employee" ("worker_id") ON DELETE SET NULL
);


DROP TABLE IF EXISTS "employee_skill" CASCADE ;
CREATE TABLE "employee_skill" (
 "worker_id" INT NOT NULL,
 "skill_id" INT NOT NULL,

 PRIMARY KEY ("worker_id","skill_id"),


 FOREIGN KEY ("worker_id") REFERENCES "employee" ("worker_id") ON DELETE CASCADE,
 FOREIGN KEY ("skill_id") REFERENCES "skill" ("skill_id") ON DELETE CASCADE
);


DROP TABLE IF EXISTS "planned_activity" CASCADE ;
CREATE TABLE "planned_activity" (
 "activity_id" INT NOT NULL,
 "instance_id" INT NOT NULL,
 "planned_hours" INT NOT NULL,

 PRIMARY KEY ("activity_id","instance_id"),

 FOREIGN KEY ("activity_id") REFERENCES "teaching_activity" ("activity_id") ON DELETE CASCADE,
 FOREIGN KEY ("instance_id") REFERENCES "course_instance" ("instance_id") ON DELETE CASCADE
);


DROP TABLE IF EXISTS "salary" CASCADE ;
CREATE TABLE "salary" (
 "version" DATE NOT NULL,
 "worker_id" INT NOT NULL,
 "salary" INT NOT NULL,

 PRIMARY KEY ("version","worker_id"),

 FOREIGN KEY ("worker_id") REFERENCES "employee" ("worker_id") ON DELETE CASCADE
);


DROP TABLE IF EXISTS "allocation" CASCADE ;
CREATE TABLE "allocation" (
 "activity_id" INT NOT NULL,
 "worker_id" INT NOT NULL,
 "instance_id" INT NOT NULL,
 "hours" INT,

 PRIMARY KEY ("activity_id","worker_id","instance_id"),

 FOREIGN KEY ("activity_id","instance_id") REFERENCES "planned_activity" ("activity_id","instance_id") ON DELETE CASCADE,
 FOREIGN KEY ("worker_id") REFERENCES "employee" ("worker_id") ON DELETE CASCADE
);

DROP TABLE IF EXISTS "allocation_limit" CASCADE ;
CREATE TABLE allocation_limit(
    "max_allocation" INT NOT NULL CHECK (max_allocation > 0)

);

INSERT INTO allocation_limit VALUES (4);

CREATE OR REPLACE FUNCTION check_allocation_limit()
RETURNS TRIGGER AS $$
DECLARE 
    current_allocation INT;
    v_max_allocation INT;
    v_study_period study_period_enum;
    v_study_year INT; 
BEGIN
    SELECT ci_study_period, ci_study_year INTO v_study_period, v_study_year
    FROM course_instance ci
    WHERE instance_id = NEW.instance_id;
    SELECT COUNT(DISTINCT a.instance_id) INTO current_allocation
    FROM allocation a
    JOIN course_instance ci ON a.instance_id = ci.instance_id
    WHERE a.worker_id = NEW.worker_id
    AND ci.study_period = v_study_period
    AND ci.study_year = v_study_year;
    SELECT max_allocation INTO v_max_allocation FROM allocation_limit LIMIT 1;
    IF current_allocation + 1 > v_max_allocation THEN
        RAISE EXCEPTION 'Allocation limit exceeded for worker_id % in study_period % and study_year %', NEW.worker_id, v_study_period, v_study_year;
    END IF; 
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER allocation_VIOLATION
    BEFORE INSERT OR UPDATE 
    ON allocation
    FOR EACH ROW
    EXECUTE FUNCTION check_allocation_limit();
    

COMMENT ON TABLE "activity_factor" IS 'activity_factor';
COMMENT ON COLUMN "activity_factor"."factor" IS 'factor';
COMMENT ON TABLE "allocation_limit" IS 'allocation_limit';
COMMENT ON COLUMN "allocation_limit"."max_allocation" IS 'max_allocation';
COMMENT ON TABLE "course" IS 'course';
COMMENT ON COLUMN "course"."course_id" IS 'course_id';
COMMENT ON COLUMN "course"."course_code" IS 'course_code';
COMMENT ON TABLE "course_layout" IS 'course_layout';
COMMENT ON COLUMN "course_layout"."layout_id" IS 'layout_id';
COMMENT ON COLUMN "course_layout"."max_students" IS 'max_students';
COMMENT ON COLUMN "course_layout"."version_number" IS 'version_number';
COMMENT ON COLUMN "course_layout"."course_id" IS 'course_id';
COMMENT ON COLUMN "course_layout"."min_students" IS 'min_students';
COMMENT ON COLUMN "course_layout"."hp" IS 'hp';
COMMENT ON COLUMN "course_layout"."course_name" IS 'course_name';
COMMENT ON TABLE "department" IS 'department';
COMMENT ON COLUMN "department"."department_id" IS 'department_id';
COMMENT ON COLUMN "department"."department_name" IS 'department_name';
COMMENT ON COLUMN "department"."manager_id" IS 'manager_id';
COMMENT ON TABLE "job_title" IS 'job_title';
COMMENT ON COLUMN "job_title"."job_id" IS 'job_id';
COMMENT ON COLUMN "job_title"."job_title" IS 'job_title';
COMMENT ON TABLE "person" IS 'person';
COMMENT ON COLUMN "person"."person_id" IS 'person_id';
COMMENT ON COLUMN "person"."personal_number" IS 'personal_number';
COMMENT ON COLUMN "person"."first_name" IS 'first_name';
COMMENT ON COLUMN "person"."last_name" IS 'last_name';
COMMENT ON COLUMN "person"."phone_no" IS 'phone_no';
COMMENT ON COLUMN "person"."adress_name" IS 'adress_name';
COMMENT ON COLUMN "person"."zip" IS 'zip';
COMMENT ON COLUMN "person"."city" IS 'city';
COMMENT ON COLUMN "person"."country" IS 'country';
COMMENT ON TABLE "skill" IS 'skill';
COMMENT ON COLUMN "skill"."skill_id" IS 'skill_id';
COMMENT ON COLUMN "skill"."skill_name" IS 'skill_name';
COMMENT ON COLUMN "skill"."description" IS 'description';
COMMENT ON TABLE "teaching_activity" IS 'teaching_activity';
COMMENT ON COLUMN "teaching_activity"."activity_id" IS 'activity_id';
COMMENT ON COLUMN "teaching_activity"."activity_name" IS 'activity_name';
COMMENT ON TABLE "course_instance" IS 'course_instance';
COMMENT ON COLUMN "course_instance"."instance_id" IS 'instance_id';
COMMENT ON COLUMN "course_instance"."num_students" IS 'num_students';
COMMENT ON COLUMN "course_instance"."study_period" IS 'study_period';
COMMENT ON COLUMN "course_instance"."study_year" IS 'study_year';
COMMENT ON COLUMN "course_instance"."layout_id" IS 'layout_id';
COMMENT ON TABLE "employee" IS 'employee';
COMMENT ON COLUMN "employee"."worker_id" IS 'worker_id';
COMMENT ON COLUMN "employee"."employment_id" IS 'employment_id ';
COMMENT ON COLUMN "employee"."email" IS 'email';
COMMENT ON COLUMN "employee"."job_id" IS 'job_id';
COMMENT ON COLUMN "employee"."department_id" IS 'department_id';
COMMENT ON COLUMN "employee"."person_id" IS 'person_id';
COMMENT ON COLUMN "employee"."supervisor_id" IS 'supervisor_id';
COMMENT ON TABLE "employee_skill" IS 'employee_skill';
COMMENT ON COLUMN "employee_skill"."worker_id" IS 'worker_id';
COMMENT ON COLUMN "employee_skill"."skill_id" IS 'skill_id';
COMMENT ON TABLE "planned_activity" IS 'planned_activity';
COMMENT ON COLUMN "planned_activity"."activity_id" IS 'activity_id';
COMMENT ON COLUMN "planned_activity"."instance_id" IS 'instance_id';
COMMENT ON COLUMN "planned_activity"."planned_hours" IS 'planned_hours';
COMMENT ON TABLE "salary" IS 'salary';
COMMENT ON COLUMN "salary"."version" IS 'version';
COMMENT ON COLUMN "salary"."worker_id" IS 'worker_id';
COMMENT ON COLUMN "salary"."salary" IS 'salary';
COMMENT ON TABLE "allocation" IS 'allocation';
COMMENT ON COLUMN "allocation"."activity_id" IS 'activity_id';
COMMENT ON COLUMN "allocation"."worker_id" IS 'worker_id';
COMMENT ON COLUMN "allocation"."instance_id" IS 'instance_id';
COMMENT ON COLUMN "allocation"."hours" IS 'hours';

--
-- PostgreSQL database dump
--

\restrict XwDKMAD53xfjKpDNZGGAxAdAbx4sidr9jzb5QpRMau125B9nYJzmKE6FLBqhHk8

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-11-20 17:56:26

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 905 (class 1247 OID 16987)
-- Name: study_period_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.study_period_enum AS ENUM (
    'P1',
    'P2',
    'P3',
    'P4'
);


ALTER TYPE public.study_period_enum OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 17047)
-- Name: check_allocation_limit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_allocation_limit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
    current_allocation INT;
    v_max_allocation INT;
    v_study_period study_period_enum;
    v_study_year INT; 
BEGIN
    SELECT ci.study_period, ci.study_year INTO v_study_period, v_study_year
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
$$;


ALTER FUNCTION public.check_allocation_limit() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 16892)
-- Name: activity_factor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_factor (
    factor numeric(4,2) NOT NULL
);


ALTER TABLE public.activity_factor OWNER TO postgres;

--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE activity_factor; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.activity_factor IS 'activity_factor';


--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN activity_factor.factor; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.activity_factor.factor IS 'factor';


--
-- TOC entry 242 (class 1259 OID 17036)
-- Name: allocation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.allocation (
    activity_id integer NOT NULL,
    worker_id integer NOT NULL,
    hours integer
);


ALTER TABLE public.allocation OWNER TO postgres;

--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE allocation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.allocation IS 'allocation  ';


--
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN allocation.activity_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.allocation.activity_id IS 'activity_id';


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN allocation.worker_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.allocation.worker_id IS 'worker_id';


--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 242
-- Name: COLUMN allocation.hours; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.allocation.hours IS 'hours ';


--
-- TOC entry 243 (class 1259 OID 17042)
-- Name: allocation_limit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.allocation_limit (
    max_allocation integer NOT NULL,
    CONSTRAINT allocation_limit_max_allocation_check CHECK ((max_allocation > 0))
);


ALTER TABLE public.allocation_limit OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16897)
-- Name: course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course (
    course_id integer NOT NULL,
    course_code character(6) NOT NULL
);


ALTER TABLE public.course OWNER TO postgres;

--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE course; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.course IS 'course';


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN course.course_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course.course_id IS 'course_id ';


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN course.course_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course.course_code IS 'course_code ';


--
-- TOC entry 220 (class 1259 OID 16896)
-- Name: course_course_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.course ALTER COLUMN course_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 16978)
-- Name: course_instance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_instance (
    instance_id integer NOT NULL,
    num_students integer NOT NULL,
    study_period public.study_period_enum NOT NULL,
    study_year integer NOT NULL,
    layout_id integer NOT NULL
);


ALTER TABLE public.course_instance OWNER TO postgres;

--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE course_instance; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.course_instance IS 'course_instance';


--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN course_instance.instance_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_instance.instance_id IS 'instance_id  ';


--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN course_instance.num_students; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_instance.num_students IS 'num_students';


--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN course_instance.study_period; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_instance.study_period IS 'study_period (P1,...,P4)';


--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN course_instance.study_year; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_instance.study_year IS 'study_year';


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN course_instance.layout_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_instance.layout_id IS 'layout_id';


--
-- TOC entry 223 (class 1259 OID 16907)
-- Name: course_layout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_layout (
    layout_id integer NOT NULL,
    max_students integer NOT NULL,
    version_number integer NOT NULL,
    course_id integer NOT NULL,
    min_students integer NOT NULL,
    hp numeric(4,2) NOT NULL,
    course_name character varying(100) NOT NULL,
    CONSTRAINT chk_min_max_students CHECK ((min_students <= max_students)),
    CONSTRAINT chk_min_student CHECK ((min_students > 0))
);


ALTER TABLE public.course_layout OWNER TO postgres;

--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE course_layout; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.course_layout IS 'course_layout';


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN course_layout.layout_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_layout.layout_id IS 'layout_id';


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN course_layout.max_students; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_layout.max_students IS 'max_students';


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN course_layout.version_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_layout.version_number IS 'version_number';


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN course_layout.course_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_layout.course_id IS 'course_id';


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN course_layout.min_students; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_layout.min_students IS 'min_students';


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN course_layout.hp; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_layout.hp IS 'hp';


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN course_layout.course_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.course_layout.course_name IS 'course_name';


--
-- TOC entry 240 (class 1259 OID 17019)
-- Name: planned_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.planned_activity (
    activity_id integer NOT NULL,
    instance_id integer NOT NULL,
    planned_hours integer NOT NULL
);


ALTER TABLE public.planned_activity OWNER TO postgres;

--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE planned_activity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.planned_activity IS 'planned_activity';


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN planned_activity.activity_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.planned_activity.activity_id IS 'activity_id';


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN planned_activity.instance_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.planned_activity.instance_id IS 'instance_id  ';


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN planned_activity.planned_hours; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.planned_activity.planned_hours IS 'planned_hours';


--
-- TOC entry 244 (class 1259 OID 17133)
-- Name: course_instance_hours; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.course_instance_hours AS
 SELECT ci.instance_id,
    c.hp,
    ci.study_period,
    ci.study_year,
    sum(pa.planned_hours) AS planned_hours,
    ((32)::numeric + (0.725 * (ci.num_students)::numeric)) AS exam_hours,
    ((((2)::numeric * c.hp) + (28)::numeric) + (0.2 * (ci.num_students)::numeric)) AS admin_hours,
    (((sum(pa.planned_hours))::numeric + ((32)::numeric + (0.725 * (ci.num_students)::numeric))) + ((((2)::numeric * c.hp) + (28)::numeric) + (0.2 * (ci.num_students)::numeric))) AS total_hours
   FROM ((public.course_instance ci
     JOIN public.course_layout c ON ((c.layout_id = ci.layout_id)))
     LEFT JOIN public.planned_activity pa ON ((pa.instance_id = ci.instance_id)))
  GROUP BY ci.instance_id, c.layout_id, ci.study_period, ci.study_year, ci.num_students, c.hp;


ALTER VIEW public.course_instance_hours OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16977)
-- Name: course_instance_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.course_instance ALTER COLUMN instance_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_instance_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 16906)
-- Name: course_layout_layout_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.course_layout ALTER COLUMN layout_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_layout_layout_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 16924)
-- Name: department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department (
    department_id integer NOT NULL,
    department_name character varying(50) NOT NULL,
    manager_id integer NOT NULL
);


ALTER TABLE public.department OWNER TO postgres;

--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE department; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.department IS 'department';


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN department.department_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.department.department_id IS 'department_id';


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN department.department_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.department.department_name IS 'department_name';


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 225
-- Name: COLUMN department.manager_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.department.manager_id IS 'manager_id';


--
-- TOC entry 224 (class 1259 OID 16923)
-- Name: department_department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.department ALTER COLUMN department_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.department_department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 237 (class 1259 OID 16998)
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    worker_id integer NOT NULL,
    employment_id integer NOT NULL,
    email character varying(200) NOT NULL,
    job_id integer NOT NULL,
    department_id integer NOT NULL,
    person_id integer NOT NULL,
    supervisor_id integer
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE employee; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.employee IS 'employee';


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN employee.worker_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.employee.worker_id IS 'worker_id';


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN employee.employment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.employee.employment_id IS 'employment_id UNIQUE';


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN employee.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.employee.email IS 'email';


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN employee.job_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.employee.job_id IS 'job_id';


--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN employee.department_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.employee.department_id IS 'department_id';


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN employee.person_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.employee.person_id IS 'person_id';


--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN employee.supervisor_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.employee.supervisor_id IS 'supervisor_id';


--
-- TOC entry 238 (class 1259 OID 17011)
-- Name: employee_skill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_skill (
    worker_id integer NOT NULL,
    skill_id integer NOT NULL
);


ALTER TABLE public.employee_skill OWNER TO postgres;

--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE employee_skill; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.employee_skill IS 'employee_skill';


--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN employee_skill.worker_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.employee_skill.worker_id IS 'worker_id';


--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 238
-- Name: COLUMN employee_skill.skill_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.employee_skill.skill_id IS 'skill_id';


--
-- TOC entry 236 (class 1259 OID 16997)
-- Name: employee_worker_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.employee ALTER COLUMN worker_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.employee_worker_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 227 (class 1259 OID 16935)
-- Name: job_title; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_title (
    job_id integer NOT NULL,
    job_title character varying(100) NOT NULL
);


ALTER TABLE public.job_title OWNER TO postgres;

--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE job_title; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.job_title IS 'job_title';


--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN job_title.job_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.job_title.job_id IS 'job_id';


--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN job_title.job_title; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.job_title.job_title IS 'job_title ';


--
-- TOC entry 226 (class 1259 OID 16934)
-- Name: job_title_job_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.job_title ALTER COLUMN job_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.job_title_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 16945)
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    person_id integer NOT NULL,
    personal_number character varying(12) NOT NULL,
    first_name character(50) NOT NULL,
    last_name character varying(100) NOT NULL,
    phone_no character(10),
    adress_name character varying(50),
    zip character(5),
    city character varying(50),
    country character varying(100)
);


ALTER TABLE public.person OWNER TO postgres;

--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE person; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.person IS 'person';


--
-- TOC entry 5211 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN person.person_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.person_id IS 'person_id';


--
-- TOC entry 5212 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN person.personal_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.personal_number IS 'personal_number ';


--
-- TOC entry 5213 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN person.first_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.first_name IS 'first_name';


--
-- TOC entry 5214 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN person.last_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.last_name IS 'last_name (1-2)';


--
-- TOC entry 5215 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN person.phone_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.phone_no IS 'phone_no';


--
-- TOC entry 5216 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN person.adress_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.adress_name IS 'adress_name';


--
-- TOC entry 5217 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN person.zip; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.zip IS 'zip ';


--
-- TOC entry 5218 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN person.city; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.city IS 'city';


--
-- TOC entry 5219 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN person.country; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.person.country IS 'country';


--
-- TOC entry 228 (class 1259 OID 16944)
-- Name: person_person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.person ALTER COLUMN person_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.person_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 239 (class 1259 OID 17018)
-- Name: planned_activity_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.planned_activity ALTER COLUMN instance_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.planned_activity_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 17027)
-- Name: salary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salary (
    version date NOT NULL,
    worker_id integer NOT NULL,
    salary integer NOT NULL
);


ALTER TABLE public.salary OWNER TO postgres;

--
-- TOC entry 5220 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE salary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.salary IS 'salary';


--
-- TOC entry 5221 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN salary.version; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.salary.version IS 'version';


--
-- TOC entry 5222 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN salary.worker_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.salary.worker_id IS 'worker_id';


--
-- TOC entry 5223 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN salary.salary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.salary.salary IS 'salary';


--
-- TOC entry 231 (class 1259 OID 16959)
-- Name: skill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skill (
    skill_id integer NOT NULL,
    skill_name character varying(30),
    description text
);


ALTER TABLE public.skill OWNER TO postgres;

--
-- TOC entry 5224 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE skill; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.skill IS 'skill';


--
-- TOC entry 5225 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN skill.skill_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skill.skill_id IS 'skill_id';


--
-- TOC entry 5226 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN skill.skill_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skill.skill_name IS 'skill_name UNIQUE';


--
-- TOC entry 5227 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN skill.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skill.description IS 'description';


--
-- TOC entry 230 (class 1259 OID 16958)
-- Name: skill_skill_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.skill ALTER COLUMN skill_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.skill_skill_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 16970)
-- Name: teaching_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teaching_activity (
    activity_id integer NOT NULL,
    activity_name character varying(100) NOT NULL
);


ALTER TABLE public.teaching_activity OWNER TO postgres;

--
-- TOC entry 5228 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE teaching_activity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.teaching_activity IS 'teaching_activity';


--
-- TOC entry 5229 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN teaching_activity.activity_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.teaching_activity.activity_id IS 'activity_id';


--
-- TOC entry 5230 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN teaching_activity.activity_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.teaching_activity.activity_name IS 'activity_name';


--
-- TOC entry 232 (class 1259 OID 16969)
-- Name: teaching_activity_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.teaching_activity ALTER COLUMN activity_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.teaching_activity_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 5135 (class 0 OID 16892)
-- Dependencies: 219
-- Data for Name: activity_factor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_factor (factor) FROM stdin;
1.00
1.25
1.50
1.75
2.00
\.


--
-- TOC entry 5158 (class 0 OID 17036)
-- Dependencies: 242
-- Data for Name: allocation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.allocation (activity_id, worker_id, hours) FROM stdin;
1	17	21
2	18	24
3	20	20
4	21	23
5	17	2
1	17	21
1	17	21
1	17	21
1	17	21
1	17	21
1	17	21
1	17	21
1	17	21
\.


--
-- TOC entry 5159 (class 0 OID 17042)
-- Dependencies: 243
-- Data for Name: allocation_limit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.allocation_limit (max_allocation) FROM stdin;
4
\.


--
-- TOC entry 5137 (class 0 OID 16897)
-- Dependencies: 221
-- Data for Name: course; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course (course_id, course_code) FROM stdin;
1	CS101 
2	CS102 
3	CS201 
4	CS202 
5	CS301 
12	iv1351
13	iv1350
\.


--
-- TOC entry 5151 (class 0 OID 16978)
-- Dependencies: 235
-- Data for Name: course_instance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course_instance (instance_id, num_students, study_period, study_year, layout_id) FROM stdin;
24	28	P1	2025	1
25	22	P1	2025	2
26	35	P2	2025	3
27	30	P2	2025	4
28	18	P1	2026	5
30	28	P1	2025	5
31	28	P1	2025	4
32	28	P1	2025	3
40	150	P2	2026	4
41	190	P3	2026	3
\.


--
-- TOC entry 5139 (class 0 OID 16907)
-- Dependencies: 223
-- Data for Name: course_layout; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course_layout (layout_id, max_students, version_number, course_id, min_students, hp, course_name) FROM stdin;
1	30	1	1	10	7.50	Databases
2	25	1	2	8	7.50	Algorithms
3	40	1	3	15	7.50	Operating Systems
4	35	1	4	12	7.50	Software Engineering
5	20	1	5	5	7.50	Computer Networks
14	200	12	1	20	15.00	Databases
15	230	12	2	40	15.00	Algorithms
\.


--
-- TOC entry 5141 (class 0 OID 16924)
-- Dependencies: 225
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.department (department_id, department_name, manager_id) FROM stdin;
1	Computer Science	1
2	Mathematics	2
3	Physics	3
4	Chemistry	4
5	Biology	5
\.


--
-- TOC entry 5153 (class 0 OID 16998)
-- Dependencies: 237
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (worker_id, employment_id, email, job_id, department_id, person_id, supervisor_id) FROM stdin;
17	1001	hanna.andersson@kth.se	1	1	2	\N
18	1002	oscar.andersson@kth.se	1	2	2	\N
19	1003	hanna.olsson@kth.se	1	3	2	\N
20	1004	anna.karlsson@kth.se	1	3	5	\N
21	1005	sara.nilsson@kth.se	1	5	18	\N
\.


--
-- TOC entry 5154 (class 0 OID 17011)
-- Dependencies: 238
-- Data for Name: employee_skill; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee_skill (worker_id, skill_id) FROM stdin;
17	1
18	1
20	1
18	2
19	5
\.


--
-- TOC entry 5143 (class 0 OID 16935)
-- Dependencies: 227
-- Data for Name: job_title; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_title (job_id, job_title) FROM stdin;
1	Professor
2	Associate Professor
3	Assistant Professor
4	Lecturer
5	Researcher
6	Administrator
\.


--
-- TOC entry 5145 (class 0 OID 16945)
-- Dependencies: 229
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person (person_id, personal_number, first_name, last_name, phone_no, adress_name, zip, city, country) FROM stdin;
2	199001011234	Hanna                                             	Andersson	0701234567	Storgatan 12	12345	Stockholm	Sweden
4	199001011204	Oscar                                             	Andersson	0701230567	Storgatan 12	12345	Stockholm	Sweden
5	200401057701	Hanna                                             	OLSSON	133925879 	Storgatan 67	85435	onsala	bing
8	199001001234	Linn                                              	Andersson	0701204567	Storgatan 12	12345	Stockholm	Sweden
9	198512309876	Anna                                              	Karlsson	0709876543	Sveavägen 45	11122	Stockholm	Sweden
10	197703152345	Erik                                              	Johansson	0734567890	Kungsgatan 7	41111	Göteborg	Sweden
11	200205061111	Sara                                              	Nilsson	0721112233	Västra Hamngatan 3	22222	Malmö	Sweden
12	199912312222	Oskar                                             	Berg	0763334444	Norrlandsgatan 9	33333	Uppsala	Sweden
18	199204064470	Joe                                               	Jonas	0701204154	Bing bing bong 3	12345	Stockholm	Sweden
19	198512301876	Shawn                                             	Karlsson	0709872543	SixSeven 45	11122	Gävle	Sweden
20	197703132345	Lina                                              	Johansson	0734562890	Plangatan 7	41111	Halmstad	Sweden
21	200205361111	Ursula                                            	Nilsson	0721111233	Västra Hamngatan 3	22222	Malmö	Sweden
22	199915312222	Bengt                                             	Berg	0763334454	Svalandsgatan 9	33333	Uppsala	Sweden
29	199214064470	Joe                                               	Jonas	1701204154	Bing bing bong 3	12345	Stockholm	Sweden
30	198512302876	Shawn                                             	Karlsson	1709872543	SixSeven 45	11122	Gävle	Sweden
31	197703132645	Zara                                              	Ymer	070458357 	Midnight 7	41111	Halmstad	Sweden
32	196705361111	Tim                                               	Bradford	0506939202	Boot 3	22222	Malmö	Sweden
33	200415312222	Lucy                                              	Howard	0304567220	Hummergatan 9	33333	Uppsala	Sweden
53	199214464470	Per                                               	Corden	1701994154	Sideeye 3	12345	Stockholm	Sweden
54	198512302806	Jacob                                             	Elordi	1721872543	Glum 45	11122	Gävle	Sweden
55	197703102645	Timo                                              	Tiny	0704583500	Midnight 7	41111	Halmstad	Sweden
56	196705360111	Robin                                             	Smith	0506969202	Boot 3	22222	Malmö	Sweden
57	200415312202	Magnum                                            	Howard	0304537220	Hummergatan 9	33333	Uppsala	Sweden
\.


--
-- TOC entry 5156 (class 0 OID 17019)
-- Dependencies: 240
-- Data for Name: planned_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.planned_activity (activity_id, instance_id, planned_hours) FROM stdin;
\.


--
-- TOC entry 5157 (class 0 OID 17027)
-- Dependencies: 241
-- Data for Name: salary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salary (version, worker_id, salary) FROM stdin;
2024-01-01	18	50000
2024-01-01	17	55000
2024-01-01	20	60000
2024-01-01	19	52000
2024-01-01	21	58000
2025-01-14	17	50500
2026-01-18	18	60000
\.


--
-- TOC entry 5147 (class 0 OID 16959)
-- Dependencies: 231
-- Data for Name: skill; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skill (skill_id, skill_name, description) FROM stdin;
1	SQL	Proficient in SQL database management and queries.
2	Python	Experienced in Python programming for data analysis and web development.
3	Java	Skilled in Java programming for application development.
4	Project Management	Able to manage projects effectively using various methodologies.
5	Data Analysis	Experienced in analyzing data to extract insights and inform decisions.
\.


--
-- TOC entry 5149 (class 0 OID 16970)
-- Dependencies: 233
-- Data for Name: teaching_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teaching_activity (activity_id, activity_name) FROM stdin;
11	Lecture
12	Lab
13	Seminar
14	Tutorials
15	Others
\.


--
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 220
-- Name: course_course_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_course_id_seq', 13, true);


--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 234
-- Name: course_instance_instance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_instance_instance_id_seq', 41, true);


--
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 222
-- Name: course_layout_layout_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_layout_layout_id_seq', 15, true);


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 224
-- Name: department_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.department_department_id_seq', 5, true);


--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 236
-- Name: employee_worker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_worker_id_seq', 21, true);


--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 226
-- Name: job_title_job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_title_job_id_seq', 6, true);


--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 228
-- Name: person_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_person_id_seq', 57, true);


--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 239
-- Name: planned_activity_instance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.planned_activity_instance_id_seq', 15, true);


--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 230
-- Name: skill_skill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.skill_skill_id_seq', 5, true);


--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 232
-- Name: teaching_activity_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teaching_activity_activity_id_seq', 15, true);


--
-- TOC entry 4933 (class 2606 OID 16903)
-- Name: course course_course_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_course_code_key UNIQUE (course_code);


--
-- TOC entry 4941 (class 2606 OID 16931)
-- Name: department department_department_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_department_name_key UNIQUE (department_name);


--
-- TOC entry 4965 (class 2606 OID 17008)
-- Name: employee employee_employment_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_employment_id_key UNIQUE (employment_id);


--
-- TOC entry 4945 (class 2606 OID 16941)
-- Name: job_title job_title_job_title_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_title
    ADD CONSTRAINT job_title_job_title_key UNIQUE (job_title);


--
-- TOC entry 4949 (class 2606 OID 16953)
-- Name: person person_personal_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_personal_number_key UNIQUE (personal_number);


--
-- TOC entry 4951 (class 2606 OID 16955)
-- Name: person person_phone_no_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_phone_no_key UNIQUE (phone_no);


--
-- TOC entry 4935 (class 2606 OID 16905)
-- Name: course pk_course; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT pk_course PRIMARY KEY (course_id);


--
-- TOC entry 4961 (class 2606 OID 16996)
-- Name: course_instance pk_course_instance; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT pk_course_instance PRIMARY KEY (instance_id);


--
-- TOC entry 4937 (class 2606 OID 16918)
-- Name: course_layout pk_course_layout; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_layout
    ADD CONSTRAINT pk_course_layout PRIMARY KEY (layout_id);


--
-- TOC entry 4943 (class 2606 OID 16933)
-- Name: department pk_department; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT pk_department PRIMARY KEY (department_id);


--
-- TOC entry 4967 (class 2606 OID 17010)
-- Name: employee pk_employee; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT pk_employee PRIMARY KEY (worker_id);


--
-- TOC entry 4969 (class 2606 OID 17017)
-- Name: employee_skill pk_employee_skill; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_skill
    ADD CONSTRAINT pk_employee_skill PRIMARY KEY (worker_id, skill_id);


--
-- TOC entry 4947 (class 2606 OID 16943)
-- Name: job_title pk_job_title; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_title
    ADD CONSTRAINT pk_job_title PRIMARY KEY (job_id);


--
-- TOC entry 4953 (class 2606 OID 16957)
-- Name: person pk_person; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT pk_person PRIMARY KEY (person_id);


--
-- TOC entry 4971 (class 2606 OID 17026)
-- Name: planned_activity pk_planned_activity; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planned_activity
    ADD CONSTRAINT pk_planned_activity PRIMARY KEY (activity_id, instance_id);


--
-- TOC entry 4973 (class 2606 OID 17034)
-- Name: salary pk_salary; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary
    ADD CONSTRAINT pk_salary PRIMARY KEY (version, worker_id);


--
-- TOC entry 4955 (class 2606 OID 16968)
-- Name: skill pk_skill; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skill
    ADD CONSTRAINT pk_skill PRIMARY KEY (skill_id);


--
-- TOC entry 4959 (class 2606 OID 16976)
-- Name: teaching_activity pk_teaching_activity; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_activity
    ADD CONSTRAINT pk_teaching_activity PRIMARY KEY (activity_id);


--
-- TOC entry 4957 (class 2606 OID 16966)
-- Name: skill skill_skill_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skill
    ADD CONSTRAINT skill_skill_name_key UNIQUE (skill_name);


--
-- TOC entry 4963 (class 2606 OID 17132)
-- Name: course_instance uq_course_instance; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT uq_course_instance UNIQUE (layout_id, study_period, study_year);


--
-- TOC entry 4939 (class 2606 OID 16920)
-- Name: course_layout uq_course_version; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_layout
    ADD CONSTRAINT uq_course_version UNIQUE (course_id, version_number);


--
-- TOC entry 4986 (class 2620 OID 17048)
-- Name: allocation allocation_violation; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER allocation_violation BEFORE INSERT OR UPDATE ON public.allocation FOR EACH ROW EXECUTE FUNCTION public.check_allocation_limit();


--
-- TOC entry 4985 (class 2606 OID 17111)
-- Name: allocation fk_allocation_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT fk_allocation_1 FOREIGN KEY (worker_id) REFERENCES public.employee(worker_id);


--
-- TOC entry 4975 (class 2606 OID 17056)
-- Name: course_instance fk_course_instance_0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT fk_course_instance_0 FOREIGN KEY (layout_id) REFERENCES public.course_layout(layout_id);


--
-- TOC entry 4974 (class 2606 OID 17051)
-- Name: course_layout fk_course_layout_0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_layout
    ADD CONSTRAINT fk_course_layout_0 FOREIGN KEY (course_id) REFERENCES public.course(course_id);


--
-- TOC entry 4976 (class 2606 OID 17061)
-- Name: employee fk_employee_0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT fk_employee_0 FOREIGN KEY (job_id) REFERENCES public.job_title(job_id);


--
-- TOC entry 4977 (class 2606 OID 17066)
-- Name: employee fk_employee_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT fk_employee_1 FOREIGN KEY (department_id) REFERENCES public.department(department_id);


--
-- TOC entry 4978 (class 2606 OID 17071)
-- Name: employee fk_employee_2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT fk_employee_2 FOREIGN KEY (person_id) REFERENCES public.person(person_id);


--
-- TOC entry 4979 (class 2606 OID 17076)
-- Name: employee fk_employee_3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT fk_employee_3 FOREIGN KEY (supervisor_id) REFERENCES public.employee(worker_id) ON DELETE SET NULL;


--
-- TOC entry 4980 (class 2606 OID 17081)
-- Name: employee_skill fk_employee_skill_0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_skill
    ADD CONSTRAINT fk_employee_skill_0 FOREIGN KEY (worker_id) REFERENCES public.employee(worker_id) ON DELETE CASCADE;


--
-- TOC entry 4981 (class 2606 OID 17086)
-- Name: employee_skill fk_employee_skill_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_skill
    ADD CONSTRAINT fk_employee_skill_1 FOREIGN KEY (skill_id) REFERENCES public.skill(skill_id) ON DELETE CASCADE;


--
-- TOC entry 4982 (class 2606 OID 17091)
-- Name: planned_activity fk_planned_activity_0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planned_activity
    ADD CONSTRAINT fk_planned_activity_0 FOREIGN KEY (activity_id) REFERENCES public.teaching_activity(activity_id) ON DELETE CASCADE;


--
-- TOC entry 4983 (class 2606 OID 17096)
-- Name: planned_activity fk_planned_activity_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planned_activity
    ADD CONSTRAINT fk_planned_activity_1 FOREIGN KEY (instance_id) REFERENCES public.course_instance(instance_id) ON DELETE CASCADE;


--
-- TOC entry 4984 (class 2606 OID 17101)
-- Name: salary fk_salary_0; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary
    ADD CONSTRAINT fk_salary_0 FOREIGN KEY (worker_id) REFERENCES public.employee(worker_id) ON DELETE CASCADE;


-- Completed on 2025-11-20 17:56:26

--
-- PostgreSQL database dump complete
--

\unrestrict XwDKMAD53xfjKpDNZGGAxAdAbx4sidr9jzb5QpRMau125B9nYJzmKE6FLBqhHk8




-- q 1 
SELECT 
    c.course_code,
    CONCAT(ci.study_year, '-', ci.instance_id) AS course_instance_id,
    cl.hp,
    ci.study_period,
    ci.num_students,

    -- Planerade timmar per aktivitetstyp
    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor ELSE 0 END) AS lecture_hours,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Lab' THEN pa.planned_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Other Overhead' THEN pa.planned_hours * ta.factor ELSE 0 END) AS other_overhead_hours,

    -- Formelbaserade timmar
    ROUND(2 * cl.hp + 28 + 0.2 * ci.num_students, 2) AS admin_hours,
    ROUND(32 + 0.725 * ci.num_students, 2) AS exam_hours,

    -- Total: planerade + admin + exam
    ROUND(
        SUM(pa.planned_hours * ta.factor)
        + (2 * cl.hp + 28 + 0.2 * ci.num_students)
        + (32 + 0.725 * ci.num_students),
        2
    ) AS total_hours

FROM 
    course_instance ci
JOIN 
    course_layout cl ON ci.layout_id = cl.layout_id
JOIN 
    course c ON cl.course_id = c.course_id
LEFT JOIN 
    planned_activity pa ON pa.instance_id = ci.instance_id
LEFT JOIN 
    teaching_activity ta ON pa.activity_id = ta.activity_id

WHERE 
    ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)

GROUP BY 
    c.course_code, ci.instance_id, cl.hp, ci.study_period, ci.num_students
ORDER BY 
    ci.study_period, c.course_code;
-- q 2
SELECT 
    c.course_code,
    CONCAT(ci.study_year, '-', ci.instance_id) AS course_instance_id,
    cl.hp,
    ci.study_period,
    ci.study_year,
    ci.num_students,
    CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,
    jt.job_title AS designation,

    -- Allokerade timmar per aktivitet
    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN a.allocated_hours * ta.factor ELSE 0 END) AS lecture,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN a.allocated_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Lab' THEN a.allocated_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN a.allocated_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Other Overhead' THEN a.allocated_hours * ta.factor ELSE 0 END) AS other_overhead,

    -- Formelbaserade timmar
    ROUND(2 * cl.hp + 28 + 0.2 * ci.num_students, 2) AS admin_hours,
    ROUND(32 + 0.725 * ci.num_students, 2) AS exam_hours,

    -- Total: allokerade + admin + exam
    ROUND(
        SUM(a.allocated_hours * ta.factor)
        + (2 * cl.hp + 28 + 0.2 * ci.num_students)
        + (32 + 0.725 * ci.num_students),
        2
    ) AS total_hours

FROM 
    allocation a
JOIN 
    planned_activity pa ON a.activity_id = pa.activity_id AND a.instance_id = pa.instance_id
JOIN 
    teaching_activity ta ON pa.activity_id = ta.activity_id
JOIN 
    course_instance ci ON a.instance_id = ci.instance_id
JOIN 
    course_layout cl ON ci.layout_id = cl.layout_id
JOIN 
    course c ON cl.course_id = c.course_id
JOIN 
    employee e ON a.worker_id = e.worker_id
JOIN 
    person p ON e.person_id = p.person_id
JOIN 
    job_title jt ON e.job_id = jt.job_id

WHERE 
    ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)
    AND c.course_code = 'CS101'

GROUP BY 
    c.course_code, ci.instance_id, cl.hp, ci.study_period, ci.study_year, ci.num_students, teacher_name, jt.job_title
ORDER BY 
    course_code, teacher_name;
-- q 3
SELECT 
    c.course_code,
    CONCAT(ci.study_year, '-', ci.instance_id) AS course_instance_id,
    cl.hp,
    ci.study_period,
    ci.study_year,
    ci.num_students,
    CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,

    -- Allokerade timmar per aktivitet
    SUM(CASE WHEN ta.activity_name = 'Lecture' THEN a.allocated_hours * ta.factor ELSE 0 END) AS lecture_hours,
    SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN a.allocated_hours * ta.factor ELSE 0 END) AS tutorial_hours,
    SUM(CASE WHEN ta.activity_name = 'Lab' THEN a.allocated_hours * ta.factor ELSE 0 END) AS lab_hours,
    SUM(CASE WHEN ta.activity_name = 'Seminar' THEN a.allocated_hours * ta.factor ELSE 0 END) AS seminar_hours,
    SUM(CASE WHEN ta.activity_name = 'Other Overhead' THEN a.allocated_hours * ta.factor ELSE 0 END) AS other_overhead_hours,

    -- Formelbaserade timmar
    ROUND(32 + 0.725 * ci.num_students, 2) AS exam_hours,
    ROUND(2 * cl.hp + 28 + 0.2 * ci.num_students, 2) AS admin_hours,

    -- Total: allokerade + admin + exam
    ROUND(
        SUM(a.allocated_hours * ta.factor)
        + (32 + 0.725 * ci.num_students)
        + (2 * cl.hp + 28 + 0.2 * ci.num_students),
        2
    ) AS total_hours

FROM 
    allocation a
JOIN 
    planned_activity pa ON a.activity_id = pa.activity_id AND a.instance_id = pa.instance_id
JOIN 
    teaching_activity ta ON pa.activity_id = ta.activity_id
JOIN 
    course_instance ci ON a.instance_id = ci.instance_id
JOIN 
    course_layout cl ON ci.layout_id = cl.layout_id
JOIN 
    course c ON cl.course_id = c.course_id
JOIN 
    employee e ON a.worker_id = e.worker_id
JOIN 
    person p ON e.person_id = p.person_id

WHERE 
    ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)
    AND ci.study_period = 'Alice Smith'  

GROUP BY 
    c.course_code, ci.instance_id, cl.hp, ci.study_period, ci.study_year, ci.num_students, teacher_name
ORDER BY 
    teacher_name, ci.study_period;

-- q 4


SELECT 
    e.employment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,
    ci.study_period,
    COUNT(DISTINCT a.instance_id) AS no_of_courses
FROM 
    allocation a
JOIN 
    course_instance ci ON a.instance_id = ci.instance_id
JOIN 
    employee e ON a.worker_id = e.worker_id
JOIN 
    person p ON e.person_id = p.person_id
WHERE 
    ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)
    AND ci.study_period = 'P1'  -- byt till önskad period
GROUP BY 
    e.employment_id, teacher_name, ci.study_period
HAVING 
    COUNT(DISTINCT a.instance_id) > 1
ORDER BY 
    no_of_courses DESC;



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
     AND   CONCAT(p.first_name, ' ', p.last_name) = 'Ethan Hunt'  

GROUP BY 
    c.course_code, ci.instance_id, cl.hp, ci.study_period, ci.study_year, ci.num_students, teacher_name
ORDER BY 
    teacher_name, ci.study_period;

-- q 4

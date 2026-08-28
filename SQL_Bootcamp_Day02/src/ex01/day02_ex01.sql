SELECT gs::date AS missing_date
FROM generate_series('2022-01-01', '2022-01-10', interval '1 day') AS gs
LEFT JOIN person_visits
       ON person_visits.visit_date = gs
      AND (person_visits.person_id = 1 OR person_visits.person_id = 2)
WHERE person_visits.visit_date IS NULL
ORDER BY missing_date;

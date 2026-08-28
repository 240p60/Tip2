WITH gs AS (
    SELECT generate_series('2022-01-01', '2022-01-10', interval '1 day')::date AS missing_date
)
SELECT gs.missing_date
FROM gs
LEFT JOIN person_visits
       ON person_visits.visit_date = gs.missing_date
      AND (person_visits.person_id = 1 OR person_visits.person_id = 2)
WHERE person_visits.visit_date IS NULL
ORDER BY gs.missing_date;

INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
SELECT (SELECT MAX(id) FROM person_visits) + 1,
       (SELECT id FROM person WHERE name = 'Denis'),
       (SELECT id FROM pizzeria WHERE name = 'Dominos'),
       '2022-02-24'
UNION ALL
SELECT (SELECT MAX(id) FROM person_visits) + 2,
       (SELECT id FROM person WHERE name = 'Irina'),
       (SELECT id FROM pizzeria WHERE name = 'Dominos'),
       '2022-02-24';

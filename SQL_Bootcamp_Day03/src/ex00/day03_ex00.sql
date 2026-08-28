SELECT menu.pizza_name,
       menu.price,
       pizzeria.name AS pizzeria_name,
       person_visits.visit_date
FROM person_visits
JOIN person ON person.id = person_visits.person_id
JOIN menu ON menu.pizzeria_id = person_visits.pizzeria_id
JOIN pizzeria ON pizzeria.id = menu.pizzeria_id
WHERE person.name = 'Kate'
  AND menu.price BETWEEN 800 AND 1000
ORDER BY pizza_name, price, pizzeria_name;

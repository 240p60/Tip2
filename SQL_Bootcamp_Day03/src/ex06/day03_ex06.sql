SELECT m1.pizza_name,
       p1.name AS pizzeria_name_1,
       p2.name AS pizzeria_name_2,
       m1.price
FROM menu m1
JOIN menu m2 ON m1.id > m2.id
            AND m1.pizza_name = m2.pizza_name
            AND m1.price = m2.price
JOIN pizzeria p1 ON p1.id = m1.pizzeria_id
JOIN pizzeria p2 ON p2.id = m2.pizzeria_id
ORDER BY m1.pizza_name;

-- Задание 09. Имена людей и названия пиццерий на основе таблицы person_visits
-- с датами посещений с 7 по 9 января 2022 года включительно.
-- Внутренний запрос в части FROM + внутренние запросы в части SELECT.
-- Сортировка: по имени человека по возрастанию, по названию пиццерии по убыванию.
-- Запрещено: все виды JOIN.

SELECT (SELECT name
        FROM person
        WHERE id = pv.person_id) AS person_name,
       (SELECT name
        FROM pizzeria
        WHERE id = pv.pizzeria_id) AS pizzeria_name
FROM (SELECT person_id,
             pizzeria_id
      FROM person_visits
      WHERE visit_date BETWEEN DATE '2022-01-07' AND DATE '2022-01-09') AS pv
ORDER BY person_name ASC,
         pizzeria_name DESC;

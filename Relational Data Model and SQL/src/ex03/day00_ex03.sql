-- Задание 03. Уникальные идентификаторы людей, посетивших пиццерии
-- с 6 по 9 января 2022 года включительно ЛИБО посетивших пиццерию с id = 2.
-- Сортировка по идентификатору человека по убыванию.

SELECT DISTINCT person_id
FROM person_visits
WHERE (visit_date BETWEEN DATE '2022-01-06' AND DATE '2022-01-09')
   OR pizzeria_id = 2
ORDER BY person_id DESC;

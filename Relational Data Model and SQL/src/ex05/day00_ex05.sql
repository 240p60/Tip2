-- Задание 05. Имена людей, сделавших заказы по меню с id 13, 14, 18
-- за 7 января 2022 года. Имя получаем внутренним запросом в части SELECT.
-- Запрещено: IN, все виды JOIN.

SELECT (SELECT name
        FROM person
        WHERE id = person_order.person_id) AS person_name
FROM person_order
WHERE (menu_id = 13 OR menu_id = 14 OR menu_id = 18)
  AND order_date = DATE '2022-01-07';

-- Задание 08. Все столбцы из таблицы person_order, где идентификатор — чётное число.
-- Сортировка по идентификатору.

SELECT *
FROM person_order
WHERE MOD(id, 2) = 0
ORDER BY id;

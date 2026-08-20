-- Задание 02. Пиццерии (название и рейтинг) с рейтингом от 3.5 до 5 включительно,
-- отсортированные по рейтингу. Два запроса, разных по синтаксису.

-- Вариант 1: операторы сравнения (>=, <=)
SELECT name,
       rating
FROM pizzeria
WHERE rating >= 3.5
  AND rating <= 5
ORDER BY rating;

-- Вариант 2: ключевое слово BETWEEN
SELECT name,
       rating
FROM pizzeria
WHERE rating BETWEEN 3.5 AND 5
ORDER BY rating;

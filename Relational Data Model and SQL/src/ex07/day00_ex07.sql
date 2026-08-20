-- Задание 07. Идентификаторы людей, их имена и интервал по возрасту
-- в новом вычисляемом столбце interval_info:
--   if (age >= 10 and age <= 20) -> 'interval #1'
--   else if (age > 20 and age < 24) -> 'interval #2'
--   иначе -> 'interval #3'
-- Сортировка по interval_info по возрастанию.

SELECT id,
       name,
       CASE
           WHEN age >= 10 AND age <= 20 THEN 'interval #1'
           WHEN age > 20 AND age < 24 THEN 'interval #2'
           ELSE 'interval #3'
       END AS interval_info
FROM person
ORDER BY interval_info;

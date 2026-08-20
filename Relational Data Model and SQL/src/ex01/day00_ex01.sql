-- Задание 01. Имена и возраст всех женщин из города «Казань», сортировка по имени.

SELECT name,
       age
FROM person
WHERE address = 'Kazan'
  AND gender = 'female'
ORDER BY name;

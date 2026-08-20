-- Задание 04. Одно вычисляемое поле person_information в виде строки:
-- Anna (age:16,gender:'female',address:'Moscow')
-- Сортировка по вычисляемому полю по возрастанию.

SELECT name || ' (age:' || age || ',gender:''' || gender || ''',address:''' || address || ''')'
           AS person_information
FROM person
ORDER BY person_information;

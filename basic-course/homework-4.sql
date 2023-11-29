USE sakila;

-- 1. Вивести всі фільми, видані в прокат менеджером Mike Hillyer. Для визначення менеджера використати таблицю staff і поле staff_id; для визначення фільму скористатися таблицею inventory (поле inventory_id), і таблиці film (поле film_id). (Це завдання ви виконували в другому ДЗ, цього разу для виконання завдання потрібно використати common table expression)
WITH staff_cte AS (
	SELECT staff_id FROM staff
    WHERE CONCAT(first_name, ' ', last_name) = 'Mike Hillyer'
), rental_cte AS (
	SELECT inventory_id FROM rental
    WHERE staff_id IN (SELECT * FROM staff_cte)
), inventory_cte AS (
	SELECT film_id FROM inventory
    WHERE inventory_id IN (SELECT * FROM rental_cte)
), film_cte AS (
	SELECT title FROM film
	WHERE film_id IN (SELECT * FROM inventory_cte)
)
SELECT * FROM film_cte;

-- 2. Вивести користувачів, що брали в оренду фільми SWEETHEARTS SUSPECTS, TEEN APOLLO, TIMBERLAND SKY, TORQUE BOUND. (Це завдання ви виконували в другому ДЗ, цього разу для виконання завдання потрібно використати common table expression)
WITH film_cte AS (
	SELECT film_id FROM film
	WHERE title IN ('SWEETHEARTS SUSPECTS', 'TEEN APOLLO', 'TIMBERLAND SKY', 'TORQUE BOUND')
), inventory_cte AS (
	SELECT film_id FROM inventory i
    WHERE film_id IN (SELECT * FROM film_cte)
), rental_cte AS (
	SELECT customer_id FROM rental
	WHERE inventory_id IN (SELECT * FROM inventory_cte)
), customer_cte AS (
	SELECT * FROM customer
    WHERE customer_id IN (SELECT * FROM rental_cte)
)
SELECT * FROM customer_cte;

-- 3. Вивести список фільмів, неповернених в прокат, replacement_cost яких більший 10 доларів.
WITH not_returned_films_cte AS (
	SELECT i.film_id FROM rental r
    JOIN inventory i ON i.inventory_id = r.inventory_id
    WHERE r.return_date IS NULL
)
SELECT * FROM film
WHERE replacement_cost > 10 AND film_id IN (SELECT * FROM not_returned_films_cte);

-- 4. Виведіть назву фільму та загальну кількість грошей отриманих від здачі цього фільму в прокат (таблиці payment, rental, inventory, film)
SELECT
    f.title AS film_title,
    SUM(p.amount) AS total_payment
FROM
    film f
JOIN
    inventory i ON f.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
JOIN
    payment p ON r.rental_id = p.rental_id
GROUP BY
    film_title;

-- 5. Виведіть кількість rental, які були повернуті і кількість тих, які не були повернуті в прокат.
WITH count_rental_status AS (
	SELECT
		CASE
			WHEN return_date IS NULL THEN 'not returned'
            WHEN return_date IS NOT NULL THEN 'returned'
		END AS status,
        COUNT(*) AS count
	FROM rental
    GROUP BY status
)
SELECT * FROM count_rental_status;

-- 6. Напишіть запит, що повертає поля “customer”, “total_amount”. За основу взяти таблицю sakila.payment. Total_amount - це сума грошей, які заплатив кожен користувач за фільми, що брав у прокат. Результат має відображати лише тих користувачів, що заплатили більше ніж 190 доларів. Customer - це конкатенація першої літери імені та прізвища користувача. Наприклад Alan Lipton має бути представлений як A. Lipton.
SELECT
	CONCAT(SUBSTRING(c.first_name, 1, 1), '. ', SUBSTRING(c.last_name, 1, 1), LOWER(SUBSTRING(c.last_name, 2))) AS customer,
    SUM(p.amount) AS total_amount
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
GROUP BY customer
HAVING total_amount > 190;

-- 7. Виведіть інформацію про фільми, тривалість яких найменша (в даному випадку потрібно використати підзапит з агрегаційною функцією). Вивести потрібно назву фільму, категорію до якої він відноситься, прізвища та імена акторів які знімалися в фільмі.
SELECT
    f.title AS film_title,
    c.name AS category,
    GROUP_CONCAT(CONCAT(a.last_name, ' ', a.first_name)) AS actor_name
FROM
    film f
JOIN
    film_category fc ON f.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
JOIN
    film_actor fa ON f.film_id = fa.film_id
JOIN
    actor a ON fa.actor_id = a.actor_id
WHERE
    f.length = (SELECT MIN(length) FROM film)
GROUP BY
    film_title, category
ORDER BY
    film_title, category;

--8. Категоризуйте фільми за ознакою rental_rate наступним чином: якщо rental_rate нижчий за 2 - це фільм категорії low_rental_rate, якщо rental_rate від 2 до 4 - це фільм категорії medium_rental_rate, якщо rental_rate більший за 4 - це фільм категорії high_rental_rate. Відобразіть кількість фільмів що належать до кожної з категорій.
SELECT
	CASE
		WHEN rental_rate < 2 THEN 'low_rental_rate'
        WHEN rental_rate BETWEEN 2 AND 4 THEN 'medium_rental_rate'
        WHEN rental_rate > 4 THEN 'high_rental_rate'
	END AS rate_category,
    COUNT(*) AS rate_category_count
FROM film
GROUP BY rate_category;
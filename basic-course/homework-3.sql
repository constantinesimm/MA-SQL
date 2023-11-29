USE sakila;

-- Вивести прізвища та імена всіх клієнтів (customer), які не повернули фільми в прокат.
SELECT
    CONCAT(first_name, ' ', last_name) AS customer
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
WHERE r.return_date IS NULL;

-- Виведіть список всіх людей наявних в базі даних (таблиці actor, customer, staff).
-- Для виконання використайте оператор UNION. Вивести потрібно конкатенацію полів прізвище та ім’я.
SELECT CONCAT(first_name, ' ', last_name) AS people FROM actor
UNION
SELECT CONCAT(first_name, ' ', last_name) AS people FROM customer
UNION
SELECT CONCAT(first_name, ' ', last_name) AS people FROM staff;

-- Виведіть кількість міст для кожної країни.
SELECT
    cc.country,
    COUNT(c.country_id) AS cities_count
FROM city c
JOIN country cc ON cc.country_id = c.country_id
GROUP BY
    cc.country;

-- Виведіть кількість фільмів знятих в кожній категорії.
SELECT
    c.name AS category,
    COUNT(fc.film_id) AS films_count
FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
GROUP BY
    category;

-- Виведіть кількість акторів, що знімалися в кожному фільмі.
SELECT
    f.title AS film,
    COUNT(fa.actor_id) AS actors_count
FROM film f
JOIN film_actor fa ON fa.film_id = f.film_id
GROUP BY
    film;

-- Виведіть кількість акторів, що знімалися в кожній категорії фільмів.
SELECT
    c.name AS category,
    COUNT(fa.actor_id) AS actors_count
FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
JOIN film_actor fa ON fa.film_id = fc.film_id
GROUP BY
    category;

-- Виведіть district та кількість адрес для кожного district, за умови, що district починається на “Central”.
SELECT
    district,
    COUNT(address) AS address_count
FROM address
WHERE
    district LIKE 'Central%'
GROUP BY
    district;

-- За допомогою одного запиту вивести кількість фільмів в базі даних, мінімальну, середню та максимальну вартість здачі в прокат (rental_rate), середню replacement_cost, мінімальну, середню та максимальну тривалість фільмів.
SELECT
    COUNT(film_id) AS films_count,
    MIN(rental_rate) AS min_rental_rate,
    AVG(rental_rate) AS avg_rental_rate,
    MAX(rental_rate) AS max_rental_rate,
    AVG(replacement_cost) AS avg_replacement_cost,
    MIN(length) AS min_length,
    AVG(length) AS avg_length,
    MAX(length) AS max_length
FROM film;

-- Виведіть кількість активних та неактивних клієнтів. (формат: active, кількість клієнтів).
SELECT
  CASE
    WHEN active = 1 THEN 'active'
    WHEN active = 0 THEN 'inactive'
  END AS status,
  COUNT(*) AS count
FROM customer
GROUP BY
    active;

-- Виведіть ім’я та прізвище клієнта, дату його першого та останнього платежу та загальну кількість грошей, які він заплатив. (таблиці payment, customer)
SELECT DISTINCT
    CONCAT(first_name, ' ', last_name) AS name,
    MIN(p.payment_date) AS first_payment_date,
    MAX(p.payment_date) AS last_payment_date,
    SUM(p.amount) AS total_amount
FROM customer c
JOIN payment p ON p.customer_id = c.customer_id
GROUP BY
    c.customer_id;
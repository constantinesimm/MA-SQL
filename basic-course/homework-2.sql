USE sakila;

-- Вивести адресу і місто до якого відноситься ця адреса. (таблиці address, city).
-- subquery
SELECT
    a.address,
    (SELECT c.city FROM city c WHERE a.city_id = c.city_id) AS city
FROM address a
WHERE a.city_id IN (SELECT city_id FROM city);

-- join
SELECT
    a.address,
    c.city
FROM address a
JOIN city c ON a.city_id = c.city_id;

-- Вивести список міст Аргентини і Австрії. (таблиці city, country). Відсортувати за алфавітом.
-- subquery
SELECT
    c.city,
    (
        SELECT cc.country FROM country cc
        WHERE c.country_id = cc.country_id
    ) AS country
FROM city c
WHERE c.country_id IN (
    SELECT country_id FROM country cc
    WHERE cc.country IN ('Argentina', 'Austria')
)
ORDER BY c.city;

-- join
SELECT
    c.city,
    cc.country
FROM city c
JOIN country cc ON c.country_id = cc.country_id
WHERE cc.country IN ('Argentina', 'Austria')
ORDER BY c.city;

-- Вивести список акторів, що знімалися в фільмах категорій Music, Sports.
-- (використати таблиці actor, film_actor, film_category, category).
-- subquery
SELECT
    CONCAT(first_name, ' ', last_name) AS actor
FROM actor a
WHERE a.actor_id IN (
    SELECT
        fa.actor_id
    FROM film_actor fa
    WHERE fa.actor_id = a.actor_id AND
        (
            SELECT
                c.category_id
            FROM category c
            WHERE c.category_id IN (
                SELECT
                    fc.category_id
                FROM film_category fc
                WHERE fc.film_id = fa.film_id
            ) AND
            c.name IN ('Music', 'Sports')
        )
);

-- join
SELECT
    CONCAT(first_name, ' ', last_name) AS actor
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film_category fc ON fc.film_id = fa.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.name IN ('Music', 'Sports');

-- Вивести всі фільми, видані в прокат менеджером Mike Hillyer. Для
-- визначення менеджера використати таблицю staff і поле staff_id; для
-- визначення фільму скористатися таблицею inventory (поле inventory_id), і
-- таблиці film (поле film_id).
-- subquery
SELECT
    f.title
FROM film f
WHERE f.film_id IN (
    SELECT
        i.film_id
    FROM inventory i
    WHERE i.inventory_id IN (
        SELECT
            r.inventory_id
        FROM rental r
        WHERE r.staff_id = (
            SELECT
                s.staff_id
            FROM staff s
            WHERE CONCAT(s.first_name, ' ', s.last_name) = 'Mike Hillyer'
        )
    )
);

-- join
SELECT
    f.title
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN staff s ON s.staff_id = r.staff_id
WHERE CONCAT(s.first_name, ' ', s.last_name) = 'Mike Hillyer';

-- Вивести користувачів, що брали в оренду фільми SWEETHEARTS
-- SUSPECTS, TEEN APOLLO, TIMBERLAND SKY, TORQUE BOUND.
-- subquery
SELECT * FROM customer c
WHERE c.customer_id IN (
    SELECT
        r.customer_id
    FROM rental r
    WHERE r.inventory_id IN (
        SELECT
            i.film_id
        FROM inventory i
        WHERE i.film_id IN (
            SELECT
                f.film_id
            FROM film f
            WHERE f.title IN ('SWEETHEARTS SUSPECTS', 'TEEN APOLLO', 'TIMBERLAND SKY', 'TORQUE BOUND')
        )
    )
);

-- join
SELECT * FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
WHERE f.title IN ('SWEETHEARTS SUSPECTS', 'TEEN APOLLO', 'TIMBERLAND SKY', 'TORQUE BOUND');

-- Вивести назву фільму, тривалість фільму і мову фільму. Фільтр: мова
-- Англійська або італійська. (таблиці film, language).
-- subquery
SELECT
    f.title,
    f.length,
    (
        SELECT name FROM language
        WHERE language_id = f.language_id
    ) AS language
FROM film f
WHERE f.language_id IN (
    SELECT language_id FROM language
    WHERE name IN ('English', 'Italian')
);

-- join
SELECT
    f.title,
    f.length,
    l.name AS language
FROM film f
JOIN language l ON l.language_id = f.language_id
WHERE l.name IN ('English', 'Italian');

-- Вивести payment_date і amount всіх записів активних клієнтів (поле active таблиці customer).
-- subquery
SELECT
    p.payment_date,
    p.amount
FROM payment p
WHERE p.customer_id IN (
    SELECT
        customer_id
    FROM customer
    WHERE active = TRUE
);

-- join
SELECT
    p.payment_date,
    p.amount
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
WHERE c.active = TRUE;

-- Вивести прізвище та ім’я клієнтів, payment_date і amount для активних клієнтів (поле active таблиці customer).
-- subquery
SELECT
    p.payment_date,
    p.amount,
    (
        SELECT
            CONCAT(c.first_name, ' ', c.last_name)
        FROM customer c
        WHERE c.customer_id = p.customer_id
    ) AS name
FROM payment p
WHERE p.customer_id IN (
    SELECT
        customer_id
    FROM customer
    WHERE active = TRUE
);

-- join
SELECT
    p.payment_date,
    p.amount,
    CONCAT(c.first_name, ' ', c.last_name) AS name
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
WHERE c.active = TRUE;

-- Вивести прізвище та ім'я користувачів (customer), які здійснювали оплату в
-- розмірі більшому, ніж 10 доларів (таблиця payment, поле amount), також
-- вивести amount, дату оплати. Відсортувати за датою оплати.
-- subquery
SELECT
    (
        SELECT
            CONCAT(c.first_name, ' ', c.last_name)
        FROM customer c
        WHERE c.customer_id = p.customer_id
    ) AS name,
    p.amount,
    p.payment_date
FROM payment p
WHERE p.customer_id IN (
    SELECT
        customer_id
    FROM customer
    WHERE active = TRUE
) AND p.amount > 10
ORDER BY p.payment_date;

-- join
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS name,
    p.amount,
    p.payment_date
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
WHERE c.active = TRUE AND p.amount > 10
ORDER BY p.payment_date;

-- Вивести прізвище та ім’я, а також дату останнього оновлення запису (поле
-- last_update) для людей наявних в таблицях actor, customer. Також в
-- результуючому запиті передбачити можливість розрізняти акторів і користувачів.
SELECT
    CONCAT(first_name, ' ', last_name) AS name,
    last_update,
    'actor' AS category
FROM actor
UNION
SELECT
    CONCAT(first_name, ' ', last_name) AS name,
    last_update,
    'customer' AS category
FROM customer;

-- Вивести всі унікальні прізвища таблиць actor, customer, staff
SELECT
    last_name,
    'actor' AS category
FROM actor
UNION ALL
SELECT
    last_name,
    'customer' AS category
FROM customer
UNION ALL
SELECT
    last_name,
    'staff' AS category
FROM staff;
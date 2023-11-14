-- Вивести прізвища та імена всіх клієнтів (customer), які не повернули фільми в прокат.
select
    concat(first_name, ' ', last_name) as customer
from customer c
join rental r
	on r.customer_id = c.customer_id
where
    r.return_date is null;

-- Виведіть список всіх людей наявних в базі даних (таблиці actor, customer, staff).
-- Для виконання використайте оператор union. Вивести потрібно конкатенацію полів прізвище та ім’я.
select concat(first_name, ' ', last_name) as people from actor
union
select concat(first_name, ' ', last_name) as people from customer
union
select concat(first_name, ' ', last_name) as people from staff;

-- Виведіть кількість міст для кожної країни.
select
	cc.country,
	count(c.country_id) as cities_count
from city c
join country cc
	on cc.country_id = c.country_id
group by
    cc.country;

-- Виведіть кількість фільмів знятих в кожній категорії.
select
	c.name as category,
    count(fc.film_id) as films_count
from category c
join film_category fc
	on fc.category_id = c.category_id
group by
	category;

-- Виведіть кількість акторів, що знімалися в кожному фільмі.
select
	f.title as film,
    count(fa.actor_id) as actors_count
from film f
join film_actor fa
	on fa.film_id = f.film_id
group by
	film;

-- Виведіть кількість акторів, що знімалися в кожній категорії фільмів.
select
	c.name as category,
    count(fa.actor_id) as actors_count
from category c
join film_category fc
	on fc.category_id = c.category_id
join film_actor fa
	on fa.film_id = fc.film_id
group by
	category;

-- Виведіть district та кількість адрес для кожного district, за умови, що district починається на “Central”.
select
	district,
    count(address) as address_count
from address
where
	district like 'Central%'
group by
	district;

-- За допомогою одного запиту вивести кількість фільмів в базі даних, мінімальну, середню та максимальну вартість здачі в прокат (rental_rate), середню replacement_cost, мінімальну, середню та максимальну тривалість фільмів.
select
	count(film_id) as films_count,
    min(rental_rate) as min_rental_rate,
    avg(rental_rate) as avg_rental_rate,
    max(rental_rate) as max_rental_rate,
    avg(replacement_cost) as avg_replacement_cost,
    min(length) as min_length,
    avg(length) as avg_length,
    max(length) as max_length
from film;

-- Виведіть кількість активних та неактивних клієнтів.(формат: active, кількість клієнтів).
select
  case
    when active = 1 THEN 'active'
    when active = 0 THEN 'inactive'
  end as status,
  COUNT(*) as count
from customer
group by
	active;

-- Виведіть ім’я та прізвище клієнта, дату його першого та останнього платежу та загальну кількість грошей які він заплатив. (таблиці payment, customer)
select distinct
	concat(first_name, ' ', last_name) as name,
    min(p.payment_date) as first_payment_date,
    max(p.payment_date) as last_payment_date,
    sum(p.amount) as total_amount
from customer c
join payment p
	on p.customer_id = c.customer_id
group by
	c.customer_id;
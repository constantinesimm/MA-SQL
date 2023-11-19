-- 1. Вивести всі фільми, видані в прокат менеджером Mike Hillyer. Для визначення менеджера використати таблицю staff і поле staff_id; для визначення фільму скористатися таблицею inventory (поле inventory_id), і таблиці film (поле film_id). (Це завдання ви виконували в другому ДЗ, цього разу для виконання завдання потрібно використати common table expression)
with staff_cte as (
	select staff_id from staff
    where concat(first_name, ' ', last_name) = 'Mike Hillyer'
), rental_cte as (
	select inventory_id from rental
    where staff_id in (select * from staff_cte)
), inventory_cte as (
	select film_id from inventory
    where inventory_id in (select * from rental_cte)
), film_cte as (
	select title from film
	where film_id in (select * from inventory_cte)
)
select * from film_cte;

-- 2. Вивести користувачів, що брали в оренду фільми SWEETHEARTS SUSPECTS, TEEN APOLLO, TIMBERLAND SKY, TORQUE BOUND. (Це завдання ви виконували в другому ДЗ, цього разу для виконання завдання потрібно використати common table expression)
with film_cte as (
	select film_id from film
	where title in ('SWEETHEARTS SUSPECTS', 'TEEN APOLLO', 'TIMBERLAND SKY', 'TORQUE BOUND')
), inventory_cte as (
	select film_id from inventory i
    where film_id in (select * from film_cte)
), rental_cte as (
	select customer_id from rental
	where inventory_id in (select * from inventory_cte)
), customer_cte as (
	select * from customer
    where customer_id in (select * from rental_cte)
)
select * from customer_cte;

-- 3. Вивести список фільмів, неповернених в прокат, replacement_cost яких більший 10 доларів.
with not_returned_films_cte as (
	select i.film_id from rental r
    join inventory i on i.inventory_id = r.inventory_id
    where r.return_date is null
)

select * from film
where replacement_cost > 10 and film_id in (select * from not_returned_films_cte);

-- 4. Виведіть назву фільму та загальну кількість грошей отриманих від здачі цього фільму в прокат (таблиці payment, rental, inventory, film)
select
    f.title as film_title,
    SUM(p.amount) as total_payment
from
    film f
join
    inventory i on f.film_id = i.film_id
join
    rental r on i.inventory_id = r.inventory_id
join
    payment p on r.rental_id = p.rental_id
group by
   film_title;

-- 5. Виведіть кількість rental, які були повернуті і кількість тих, які не були повернуті в прокат.
with count_rental_status as (
	select
		case
			when return_date is null then 'not returned'
            when return_date is not null then 'returned'
		end as status,
        count(*) as count
	from rental
    group by status
)

select * from count_rental_status;

-- 6. Напишіть запит, що повертає поля “customer”, “total_amount”. За основу взяти таблицю sakila.payment. Total_amount - це сума грошей, які заплатив кожен користувач за фільми, що брав у прокат. Результат має відображати лише тих користувачів, що заплатили більше ніж 190 доларів. Customer - це конкатенація першої літери імені та прізвища користувача. Наприклад Alan Lipton має бути представлений як A. Lipton.
select
	concat(substring(c.first_name, 1, 1), '. ', substring(c.last_name, 1, 1), lower(substring(c.last_name, 2))) as customer,
    sum(p.amount) as total_amount
from payment p
join customer c
	on c.customer_id = p.customer_id
group by customer
having total_amount > 190;

-- 7. Виведіть інформацію про фільми, тривалість яких найменша (в даному випадку потрібно використати підзапит з агрегаційною функцією). Вивести потрібно назву фільму, категорію до якої він відноситься, прізвища та імена акторів які знімалися в фільмі.
select
    f.title as film_title,
    c.name as category,
    group_concat(concat(a.last_name, ' ', a.first_name)) AS actor_name
from
    film f
join
    film_category fc on f.film_id = fc.film_id
join
    category c on fc.category_id = c.category_id
join
    film_actor fa on f.film_id = fa.film_id
join
    actor a on fa.actor_id = a.actor_id
where
    f.length = (select min(length) from film)
group by
    film_title, category
order by
    film_title, category;

--8. Категоризуйте фільми за ознакою rental_rate наступним чином: якщо rental_rate нижчий за 2 - це фільм категорії low_rental_rate, якщо rental_rate від 2 до 4 - це фільм категорії medium_rental_rate, якщо rental_rate більший за 4 - це фільм категорії high_rental_rate. Відобразіть кількість фільмів що належать до кожної з категорій.
select
	case
		when rental_rate < 2 then 'low_rental_rate'
        when rental_rate between 2 and 4 then 'medium_rental_rate'
        when rental_rate > 4 then 'high_rental_rate'
	end as rate_category,
    count(*) as rate_category_count
from film
group by rate_category;
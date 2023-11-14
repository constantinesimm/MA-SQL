-- заюзаємо потрібну базу( у мене їх декілька і дефолтна стоїть інша :D )
use sakila;

-- Вивести адресу і місто до якого відноситься ця адреса. (таблиці address,city).
-- subquery
select
	a.address,
    (select c.city from city c where a.city_id = c.city_id) as city
from address a
where
    a.city_id in (select city_id from city);

-- join
select
	a.address,
    c.city
from address a
join city c
	on a.city_id = c.city_id;

-- Вивести список міст Аргентини і Австрії. (таблиці city, country). Відсортувати за алфавітом.
-- subquery
select
	c.city,
	(
	    select cc.country from country cc
	    where c.country_id = cc.country_id
	) as country
from city c
where
    c.country_id in
    (
        select country_id from country cc
        where
            cc.country in ('Argentina', 'Austria')
    )
order by c.city;

-- join
select
	c.city,
    cc.country
from city c
join country cc
	on c.country_id = cc.country_id
where
    cc.country in ('Argentina', 'Austria')
order by c.city;

-- Вивести список акторів, що знімалися в фільмах категорій Music, Sports.
-- (використати таблиці actor, film_actor, film_category, category).
-- subquery
select
	concat(first_name, ' ', last_name) as actor
from actor a
where
    a.actor_id in
        (
            select
                fa.actor_id
            from film_actor fa
            where
                fa.actor_id = a.actor_id and
                (
                    select
                        c.category_id
                    from category c
                    where
                        c.category_id in
                        (
                            select
                                fc.category_id
                            from film_category fc
                            where
                                fc.film_id = fa.film_id
                        ) and
                        c.name in ('Music', 'Sports')
                )
        );

-- join
select
	concat(first_name, ' ', last_name) as actor
from actor a
join film_actor fa
	on fa.actor_id = a.actor_id
join film_category fc
	on fc.film_id = fa.film_id
join category c
	on c.category_id = fc.category_id
where
    c.name in ('Music', 'Sports');

-- Вивести всі фільми, видані в прокат менеджером Mike Hillyer. Для
-- визначення менеджера використати таблицю staff і поле staff_id; для
-- визначення фільму скористатися таблицею inventory (поле inventory_id), і
-- таблиці film (поле film_id).
-- subquery
select
  f.title
from film f
where
    f.film_id IN (
      select
        i.film_id
      from inventory i
      where
        i.inventory_id IN (
            select
                r.inventory_id
            from rental r
            where
                r.staff_id = (
                    select
                        s.staff_id
                    from staff s
                    where
                        concat(s.first_name, ' ', s.last_name) = 'Mike Hillyer'
                )
          )
    );

-- join
select
	f.title
from film f
join inventory i
	on i.film_id = f.film_id
join rental r
	on r.inventory_id = i.inventory_id
join staff s
	on s.staff_id = r.staff_id
where
    concat(s.first_name, ' ', s.last_name) = 'Mike Hillyer';

-- Вивести користувачів, що брали в оренду фільми SWEETHEARTS
-- SUSPECTS, TEEN APOLLO, TIMBERLAND SKY, TORQUE BOUND.
-- subquery
select * from customer c
where
	c.customer_id in
    (
		select
			r.customer_id
		from rental r
        where
			r.inventory_id in
            (
				select
					i.film_id
				from inventory i
                where
					i.film_id in
                    (
						select
							f.film_id
						from film f
                        where
							f.title in ('SWEETHEARTS SUSPECTS', 'TEEN APOLLO', 'TIMBERLAND SKY', 'TORQUE BOUND')
                    )
            )
    )

-- join
select * from customer c
join rental r
	on r.customer_id = c.customer_id
join inventory i
	on i.inventory_id = r.inventory_id
join film f
	on f.film_id = i.film_id
where
	f.title in ('SWEETHEARTS SUSPECTS', 'TEEN APOLLO', 'TIMBERLAND SKY', 'TORQUE BOUND');

-- Вивести назву фільму, тривалість фільму і мову фільму. Фільтр: мова
-- Англійська або італійська. (таблиці film, language).
-- subquery
select
	f.title,
    f.length,
    (
		select name from language
        where language_id = f.language_id
    ) as language
from film f
where
	f.language_id in
    (
		select language_id from language
        where name in ('English', 'Italian')
    );

-- join
select
	f.title,
    f.length,
    l.name as language
from film f
join language l
	on l.language_id = f.language_id
where
    l.name in ('English', 'Italian');

-- Вивести payment_date i amount всіх записів активних клієнтів (поле active таблиці customer).
-- subquery
select
	p.payment_date,
    p.amount
from payment p
where
	p.customer_id in
    (
		select
			customer_id
		from customer
        where
			active = TRUE
    );

-- join
select
	p.payment_date,
    p.amount
from payment p
join customer c
	on c.customer_id = p.customer_id
where
    c.active = TRUE;

-- Вивести прізвище та ім’я клієнтів, payment_date i amount для активнихклієнтів (поле active таблиці customer).
-- subquery
select
	p.payment_date,
    p.amount,
    (
		select
			concat(c.first_name, ' ', c.last_name)
		from customer c
        where c.customer_id = p.customer_id
    ) as name
from payment p
where
	p.customer_id in
    (
		select
			customer_id
		from customer
        where
			active = TRUE
    );

-- join
select
	p.payment_date,
    p.amount,
    concat(c.first_name, ' ', c.last_name) as name
from payment p
join customer c
	on c.customer_id = p.customer_id
where
    c.active = TRUE;

-- Вивести прізвище та ім'я користувачів (customer), які здійснювали оплату в
-- розмірі більшому, ніж 10 доларів (таблиця payment, поле amount), також
-- вивести amount, дату оплати. Відсортувати за датою оплати.
-- subquery
select
    (
		select
			concat(c.first_name, ' ', c.last_name)
		from customer c
        where c.customer_id = p.customer_id
    ) as name,
     p.amount,
    p.payment_date
from payment p
where
	p.customer_id in
    (
		select
			customer_id
		from customer
        where
			active = TRUE
    ) and
    p.amount > 10
order by p.payment_date;

-- join
select
	concat(c.first_name, ' ', c.last_name) as name,
    p.amount,
    p.payment_date
from payment p
join customer c
	on c.customer_id = p.customer_id
where
	c.active = TRUE and
    p.amount > 10
order by p.payment_date;

-- Вивести прізвище та ім’я, а також дату останнього оновлення запису (поле
-- last_update) для людей наявних в таблицях actor, customer. Також в
-- результуючому запиті передбачити можливість розрізняти акторів і користувачів.
select
	concat(first_name, ' ', last_name) as name,
    last_update,
    'actor' as category
from actor
union
select
	concat(first_name, ' ', last_name) as name,
    last_update,
    'customer' as category
from customer;

-- Вивести всі унікальні прізвища таблиць actor, customer, staff
select
	last_name,
    'actor' as category
from actor
union all
select
	last_name,
    'customer' as category
from customer
union all
select
	last_name,
    'staff' as category
from staff;
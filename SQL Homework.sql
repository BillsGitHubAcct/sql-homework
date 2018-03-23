use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
select concat( upper(first_name),' ', upper(last_name)) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
select actor_id, first_name, last_name from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select first_name, last_name from actor where LOCATE('GEN',last_name) > 0 order by last_name;

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select first_name, last_name from actor where LOCATE('LI',last_name) > 0 order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
select c.country_id, c.country from country c where c.country in ('Afghanistan','Bangladesh','China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(30) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor MODIFY middle_name blob;

-- 3c. Now delete the middle_name columm
ALTER TABLE actor DROP middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select * from 
(select a.last_name, count(a.last_name) as name_count from actor a group by last_name) as actor_counts
where name_count >= 2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d.
  UPDATE actor
        SET first_name = CASE
            WHEN first_name IN ('HARPO') THEN 'GROUCHO'
            WHEN first_name  NOT IN ('HARPO') THEN 'MUCHO GROUCHO'
        END
  WHERE actor_id = '172';
  
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, addr.address 
from staff s, address addr
where s.address_id = addr.address_id;
-- Or different way
select s.first_name, s.last_name, addr.address 
from staff s join address addr on s.address_id = addr.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name, sum(p.amount) as total_amt
from staff s, payment p
where s.staff_id = p.staff_id 
and p.payment_date > Date('2005-07-31') 
and p.payment_date < Date('2005-09-01')
group by s.first_name, s.last_name;
-- or different way
select s.first_name, s.last_name, sum(p.amount) as total_amt
from staff s inner join payment p on s.staff_id = p.staff_id 
and p.payment_date > Date('2005-07-31') 
and p.payment_date < Date('2005-09-01')
group by s.first_name, s.last_name;	

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join
select f.title as 'film',count(fa.actor_id) as 'number of actors' from film f, film_actor fa 
where f.film_id = fa.film_id
group by f.film_id
order by f.title;
-- Or different way
select f.title as 'film',count(fa.actor_id) as 'number of actors' 
from film f join film_actor fa on f.film_id = fa.film_id
group by f.film_id
order by f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title as 'film', count(i.inventory_id) as 'number of copies'
from film f join inventory i on f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select concat(c.last_name, ', ', c.first_name) as customer, sum(p.amount) as 'total paid'
from customer c join payment p on c.customer_id = p.customer_id
group by c.customer_id
order by c.last_name, c.first_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select f1.title as 'Movies in English starting with letters K or Q'
from film f1
where f1.title in (select f2.title from film f2 join language l on f2.language_id = l.language_id
					where (f2.title like 'Q%' or f2.title like 'K%') and l.name = 'English');
                    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select concat(a.first_name, ' ',a.last_name) as 'Actors appearing in Alone Trip'
from actor a join film_actor fa on a.actor_id = fa.actor_id
where fa.film_id in (select f.film_id from film f where f.title = 'Alone Trip')
group by a.actor_id
order by a.last_name;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select concat(c.first_name, ' ',c.last_name) as 'customers in canada', c.email
from customer c, address a, city cy, country ct
where 
	c.address_id = a.address_id and
    a.city_id = cy.city_id and 
    cy.country_id = ct.country_id and 
    ct.country = 'Canada';
-- Or different way   
SELECT concat(c.first_name, ' ',c.last_name) as 'customers in canada', c.email
FROM customer c
JOIN address a ON (c.address_id = a.address_id)
JOIN city cy ON (a.city_id = cy.city_id)
JOIN country ct ON (cy.country_id = ct.country_id)
where ct.country = 'Canada';
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select f.title as 'Family Films' 
from film f join 
	(film_category fc join category c on fc.category_id = c.category_id and c.name = 'Family')
    on f.film_id = fc.film_id;
-- Or different way
select f.title as 'Family Films'
from film f, film_category fc, category c
where
	f.film_id = fc.film_id and
    fc.category_id = c.category_id and
    c.name = 'Family';
    
-- 7e. Display the most frequently rented movies in descending order.
select f.title as 'Move Title', count(re.rental_id) as 'number of rentals'
	from film f join (inventory i join rental re on i.inventory_id = re.inventory_id)
    on f.film_id = i.film_id
    group by f.title
    order by count(re.rental_id) desc;
-- Or different way
select f.title as 'Move Title', count(re.rental_id) as 'number of rentals'
	from film f, inventory i, rental re
    where f.film_id = i.film_id and
		  i.inventory_id = re.inventory_id
	group by f.title
    order by count(re.rental_id) desc;
    
-- 7f. Write a query to display how much business, in dollars, each store brought in
select s.store_id as 'store #', sum(p.amount) as 'total sales'
from store s
	JOIN inventory i ON (i.store_id = s.store_id)
	JOIN rental r ON 	(r.inventory_id = i.inventory_id)
	JOIN payment p ON 	(p.rental_id = r.rental_id)
group by s.store_id
order by s.store_id;
-- Or Using existing View
select * from sales_by_store;
-- Or Using SQL from View
select concat(`c`.`city`,_utf8',',`cy`.`country`) AS `store`,
	   concat(`m`.`first_name`,_utf8' ',`m`.`last_name`) AS `manager`,
       sum(`p`.`amount`) AS `total_sales` 
from (((((((`sakila`.`payment` `p` join `sakila`.`rental` `r` on((`p`.`rental_id` = `r`.`rental_id`))) 
			join `sakila`.`inventory` `i` on((`r`.`inventory_id` = `i`.`inventory_id`))) 
            join `sakila`.`store` `s` on((`i`.`store_id` = `s`.`store_id`))) 
            join `sakila`.`address` `a` on((`s`.`address_id` = `a`.`address_id`))) 
            join `sakila`.`city` `c` on((`a`.`city_id` = `c`.`city_id`))) 
            join `sakila`.`country` `cy` on((`c`.`country_id` = `cy`.`country_id`))) 
            join `sakila`.`staff` `m` on((`s`.`manager_staff_id` = `m`.`staff_id`))) 
group by `s`.`store_id` 
order by `cy`.`country`,`c`.`city`;
-- OR different way using View logic
select concat(`c`.`city`,_utf8',',`cy`.`country`) AS `store`,
	   concat(`m`.`first_name`,_utf8' ',`m`.`last_name`) AS `manager`,
       sum(`p`.`amount`) AS `total_sales`
from   city c, payment p, inventory i, store s, address a, country cy, staff m , rental r
where p.rental_id = r.rental_id and
	  r.inventory_id = i.inventory_id and 
      i.store_id = s.store_id and 
      s.address_id = a.address_id and 
      a.city_id = c.city_id and
      c.country_id = cy.country_id and 
      s.manager_staff_id = m.staff_id
group by s.store_id
order by cy.country, c.city;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, cy.country
from store s, address a, city c, country cy
where s.address_id = a.address_id and
	  a.city_id = c.city_id and 
      c.country_id = cy.country_id
group by s.store_id
order by s.store_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.).)
select c.name as 'Genre', sum(p.amount) as 'Gross'
from category c, film_category fc, inventory i, payment p, rental r
where c.category_id = fc.category_id and
	  fc.film_id = i.film_id and
	  i.inventory_id = r.inventory_id and
	  r.rental_id = p.rental_id
group by c.name
order by sum(p.amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.		  
Create view sakila.top_5_Genres as 
select c.name as 'Genre', sum(p.amount) as 'Gross'
from category c, film_category fc, inventory i, payment p, rental r
where c.category_id = fc.category_id and
	  fc.film_id = i.film_id and
	  i.inventory_id = r.inventory_id and
	  r.rental_id = p.rental_id
group by c.name
order by sum(p.amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a? 
select * from sakila.top_5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it
drop view sakila.top_5_genres;

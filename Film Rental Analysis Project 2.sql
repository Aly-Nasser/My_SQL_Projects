/*THE SITUATION
You and your business partner were recently approached by another local business owner who is interested
in purchasing Maven Movies. He primarily owns restaurants and bars, so he has lots of questions for you 
about your business and the rental business in general. His offer seems very generous, so you are going 
to entertain his questions.

THE OBJECTIVE
Use MySQL to:
Leverage your SQL skills to extract and analyze data from various tables in the Maven Movies database to
answer your potential Acquirer’s questions. Each question will require you to write a multi table SQL query,
 joining at least two tables.
*/

/* QUESTION 1
My partner and I want to come by each of the stores in person and meet the managers. Please send over
the managers’ names at each store, with the full address of each property (street address, district, city, and
country please).*/
SELECT first_name , last_name, address, district , city , country
FROM store as so
JOIN staff AS st ON so.manager_staff_id = st.staff_id
JOIN address AS a ON a.address_id = so.address_id
JOIN city AS ci ON a.city_id = ci.city_id 
JOIN country AS co ON ci.country_id = co.country_id;

/* QUESTION 2
I would like to get a better understanding of all of the inventory that would come along with the business.
Please pull together a list of each inventory item you have stocked, including the store_id number, the
inventory_id , the name of the film, the film’s rating, its rental rate and replacement cost.*/

SELECT i.store_id, inventory_id , f.title, f.rating , f.rental_rate , f.replacement_cost , count(f.film_id) AS NUMBER_OF_FILMS
FROM inventory AS i
JOIN film AS f ON i.film_id = f.film_id
GROUP BY f.film_id;

/* QUESTION 3
From the same list of films you just pulled, please roll that data up and provide a summary level overview of
your inventory. We would like to know how many inventory items you have with each rating at each store.*/
SELECT i.store_id, f.title, f.rating , f.rental_rate , count(f.film_id) AS NUMBER_OF_FILMS
FROM inventory AS i
JOIN film AS f ON i.film_id = f.film_id
GROUP BY f.film_id;

/* QUESTION 4
Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement
cost, sliced by store and film category.*/

SELECT  i.store_id , c.name ,COUNT(f.film_id) as number_of_films , 
		AVG(replacement_cost) as Averger_cost, 
		SUM(replacement_cost) as Total_cost
FROM film as f
LEFT JOIN film_category AS fc ON f.film_id = fc.film_id
LEFT JOIN category AS c ON fc.category_id = c.category_id 
LEFT JOIN inventory AS i ON i.film_id = f.film_id
GROUP BY i.store_id, c.name;

/* QUESTION 5
We want to make sure you folks have a good handle on who your customers are. Please provide a list
of all customer names, which store they go to, whether or not they are currently active, and their full
addresses street address, city, and country.*/

SELECT store_id ,first_name , last_name, address, district, city, co.country,
	CASE WHEN active = 1 Then 'Active' ELSE 'Not Active' End AS Status
FROM customer as cu
LEFT JOIN address as ad ON cu.address_id = ad.address_id
LEFT JOIN city as ci ON ci.city_id = ad.city_id
LEFT JOIN country as co ON co.country_id = ci.country_id;

/* QUESTION 6
We would like to understand how much your customers are spending with you, and also to know who your
most valuable customers are. Please pull together a list of customer names, their total lifetime rentals, and the
sum of all payments you have collected from them. It would be great to see this ordered on total lifetime value,
with the most valuable customers at the top of the list.*/

SELECT r.customer_id, SUM(f.rental_duration) AS total_lifetime, sum(amount) AS total_payment
FROM rental as r
	JOIN customer as c ON r.customer_id = c.customer_id
	JOIN inventory as i ON i.inventory_id = r.inventory_id
	JOIN film as f ON f.film_id = i.film_id
	JOIN payment as p ON p.rental_id = r.rental_id
GROUP BY r.customer_id
ORDER BY total_payment DESC , total_lifetime DESC;

/* QUESTION 7
My partner and I would like to get to know your board of advisors and any current investors. Could you
please provide a list of advisor and investor names in one table? Could you please note whether they are an
investor or an advisor, and for the investors, it would be good to include which company they work with.*/

SELECT 'advisor' As result , first_name , last_name , COALESCE('NULL' , is_chairmain) as Company_name
From advisor
UNION 
SELECT 'investor' As result , first_name , last_name , company_name
FROM investor;

/* QUESTION 8
We're interested in how well you have covered the most awarded actors. Of all the actors with three types 
of awards, for what % of them do we carry a film? And how about for actors with two types of awards? Same
questions. Finally, how about actors with just one award? */

SELECT
	CASE
		WHEN awards ='Emmy, Oscar, Tony ' THEN '3 awards'
		WHEN awards IN ('Emmy, Oscar','Emmy, Tony','Oscar, Tony') THEN '2 awards'
		ELSE'1 award'
	END AS number_of_awards,
    AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS '% One Film'
FROM actor_award
GROUP BY number_of_awards;

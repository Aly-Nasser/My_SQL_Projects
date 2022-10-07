# INTRODUCING THE PROJECT
/*  THE SITUATION
The company’s insurance policy is up for renewal and the insurance company’s underwriters
need some updated information from us before they will issue a new policy. 

THE OBJECTIVE
Use MySQL to: Leverage your SQL skills to extract and analyze data from various tables in the Maven
Movies database to answer the underwriters’ questions. Each question can be answered
by querying just one table. Part of your job as an Analyst is figuring out which table to use.*/

/* QUESTIONS TO BE ANSWERED*/

/* QUESTION 1
We will need a list of all staff members, including their first and last names, 
email addresses, and the store identification number where they work.*/
SELECT staff_id , first_name, last_name , email, store_id
FROM staff;

/* QUESTION 2
We will need separate counts of inventory items held at each of your two stores.*/
SELECT store_id , COUNT(inventory_id) AS COUNT_OF_INVE_BY_STORE
FROM inventory 
group by store_id;

/*  QUESTION 3
We will need a count of active customers for each of your stores. Separately, please.*/
SELECT store_id , sum(active) AS count_of_active
FROM customer
group by store_id;

/*  QUESTION 4
In order to assess the liability of a data breach, we will need you to provide a count of all customer email
 addresses stored in the database.*/

SELECT count(email) AS count_of_emails
FROM customer;

/*  QUESTION 5
We are interested in how diverse your film offering is as a means of understanding how likely you are to
keep customers engaged in the future. Please provide a count of unique film titles you have in inventory at
 each store and then provide a count of the unique categories of films you provide.*/

SELECT store_id, category.name, COUNT(DISTINCT(inventory.film_id)) AS num_of_films
FROM inventory
JOIN film_category ON inventory.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY  store_id , category.name
ORDER BY category.name;

/*	QUESTION 6
We would like to understand the replacement cost of your films. Please provide the replacement cost for the
film that is least expensive to replace, the most expensive to replace, and the average of all films you carry.*/
SELECT MIN(replacement_cost) AS 'least expensive',
		MAX(replacement_cost) AS 'most expensive',
		AVG(replacement_cost) AS 'average'
FROM film;

/* QUESTION 7
We are interested in having you put payment monitoring systems and maximum payment processing
restrictions in place in order to minimize the future risk of fraud by your staff. Please provide the average
payment you process, as well as the maximum payment you have processed.*/

SELECT AVG(amount) AS 'average payment' , 
		MAX(amount) AS 'maximum payment'
		#SUM(amount) as 'Total Payment Processed'
FROM payment;

/* QUESTION 8
We would like to better understand what your customer base looks like. Please provide a list of all customer
identification values, with a count of rentals they have made all time, with your highest volume customers at
the top of the list.*/

SELECT customer_id,count(customer_id) AS count_of_rental
FROM rental
GROUP BY customer_id
ORDER BY count_of_rental DESC
/* Normalisation and CTE queries


Question 1:
 Identify a table in the Sakila database that violates 1NF. Explain how you would normalize it to achieve 1NF.
Answer of 1st:
Actor_award table violates NF1 formation in mavenmovies database. Since it violates 1NF formation we can normalize it by updating the actor_award table , avoid multivalued (each column has only atomic values) ,  we can create separate tables for the columns which contain multiple values,  etc.
To achieve 1NF, 
SELECT awards FROM actor_award ;



Question 2:
Choose a table in Sakila and describe how you would determine whether it is in 2NF. If it violates 2NF. Explain the steps to normalize it.
Answer of 2nd:
SELECT * FROM film ; 
 film table from sakila database violates 2NF since special features column on the table violates NF and 2NF has a rule that if table is in 1NF
-- Identify Partial Dependencies: All the non-prime attributes like title , description , release_year etc are fully dependent on the primary key which is film id. 
-- We can create an another table and make them columns foreign keys and these foreign keys make reference to that film id table. 
  By using these steps we can avoid 2NF .



Question 3:
Identify a table in Sakila that violates 3NF. Describe the transitive dependencies present and outline the steps to normalise the table to 3NF.
Answer of 3rd:
On seeing the customer table in the sakila database we get to know that the column name address_id is linked with store id and both are non-key attributes and 3NF says that table is in 2NF from and it ensure that all the non key attribute column on the
 table are not related to each other (one non key attribute column related to other non key attribute column) so because of that it violates 2NF and 3NF.

Steps to prevent 3NF -

1.  Analyse the violation 
2.  Create new table to store data 
3.  Update customer table (make store id as foreign key )
4.  Update address info. (so it reference to the foreign key )
etc.
*/




-- Question 5: --
 -- Write a query using a CTE to retrieve the distinct list of actor names and the number of films they have acted in from the  actor and  film_actor tables. --
-- Answer of 5th: --
WITH ActorFilmCount AS (
    SELECT
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        COUNT(fa.film_id) AS film_count
    FROM
        actor a
    JOIN
        film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY
        a.actor_id, actor_name
)

SELECT
    actor_name,
    film_count
FROM
    ActorFilmCount
ORDER BY
    film_count DESC, actor_name ;



-- Question 6: --
-- Use a recursive CTE to generate a hierarchical list of categories and their subcategories from the category table in Sakila. --
-- Answer of 6th: --
WITH RECURSIVE CategoryHierarchy AS (
    SELECT
        c.category_id,
        c.name AS category_name,
        NULL AS parent_category_id,
        0 AS level
    FROM
        category c
    WHERE
        NOT EXISTS (
            SELECT 1
            FROM film_category fc
            WHERE fc.category_id = c.category_id
        )

    UNION ALL

    SELECT
        c.category_id,
        c.name AS category_name,
        fc.category_id AS parent_category_id,
        ch.level + 1 AS level
    FROM
        category c
    JOIN
        film_category fc ON c.category_id = fc.category_id
    JOIN
        CategoryHierarchy ch ON fc.film_id = ch.category_id
)

SELECT
    category_id,
    category_name,
    parent_category_id,
    level
FROM
    CategoryHierarchy
ORDER BY
    level, category_id ; 



-- Question 7: --
-- Create a CTE that combines information from the  film and language tables to display the films title , language , rental rate. --
-- Answer of 7th: --
 WITH FilmLanguageInfo AS (
    SELECT
        f.title AS film_title,
        l.name AS language,
        f.rental_rate
    FROM
        film f
    JOIN
        language l ON f.language_id = l.language_id
)

SELECT
    film_title,
    language,
    rental_rate
FROM
    FilmLanguageInfo;




-- Question 8: --
-- Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from customer and payment table. --
-- Answer of 8th: --
WITH CustomerRevenue AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(p.amount) AS total_revenue
    FROM
        customer c
    LEFT JOIN
        payment p ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id, customer_name
)

SELECT
    customer_id,
    customer_name,
    COALESCE(total_revenue, 0) AS total_revenue
FROM
    CustomerRevenue
ORDER BY
    total_revenue DESC;




-- Question 9: --
-- Utilize a CTE with a window function to rank films based on their rental duration from the  film table. --
-- Answer of 9th: --
WITH RankedFilms AS (
    SELECT
        film_id,
        title,
        rental_duration,
        RANK() OVER (ORDER BY rental_duration DESC) AS rental_duration_rank
    FROM
        film
)

SELECT
    film_id,
    title,
    rental_duration,
    rental_duration_rank
FROM
    RankedFilms
ORDER BY
    rental_duration_rank;




-- Question 10:--
-- Create a CTE to list customers who have made more than two rentals, and then join this CTE with the customer table to retrieve additional customer details. --

-- Answer of 10th: --
WITH CustomerRentals AS (
    SELECT
        customer_id,
        COUNT(rental_id) AS rental_count
    FROM
        rental
    GROUP BY
        customer_id
    HAVING
        COUNT(rental_id) > 2
)

SELECT
    c.*,
    cr.rental_count
FROM
    customer c
JOIN
    CustomerRentals cr ON c.customer_id = cr.customer_id
ORDER BY
    cr.rental_count DESC;




-- Question 11: --
 -- Write a query using a CTE to find the total number of rentals made each month, considering the  rental date from the rental table. --
-- Answer of 11th: --
WITH MonthlyRentals AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(rental_id) AS total_rentals
    FROM
        rental
    GROUP BY
        rental_month
)

SELECT
    rental_month,
    total_rentals
FROM
    MonthlyRentals
ORDER BY
    rental_month;





-- Question 12: --
-- Use a CTE to pivot the data from the  payment rental_date table to display the total payments made by each customer in separate columns for different payment methods. --

-- Answer of 12th: --
-- Since we dont have payment method column or any  column that specify payment type we calculate total payments made by each customer -- 

WITH CustomerPayments AS (
    SELECT
        customer_id,
        SUM(amount) AS total_payments
    FROM
        payment
    GROUP BY
        customer_id
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    cp.total_payments
FROM
    customer c
JOIN
    CustomerPayments cp ON c.customer_id = cp.customer_id;




-- Question 13: --
 -- Create a CTE to generate a report showing pairs of actors who have appeared in the same film together, using the film_actor table. --
-- Answer of 13th: --
WITH ActorPairs AS (
    SELECT
        fa1.actor_id AS actor1_id,
        fa2.actor_id AS actor2_id,
        COUNT(*) AS films_together
    FROM
        film_actor fa1
        JOIN film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
    GROUP BY
        fa1.actor_id, fa2.actor_id
    HAVING
        COUNT(*) > 0
)

SELECT
    ap.actor1_id,
    ap.actor2_id,
    ap.films_together
FROM
    ActorPairs ap;





-- Question 14: --
 -- Implement a recursive CTE to find all employees in the staff table who report to a specific manager. --
-- Answer of 14th: --
 SELECT * from staff ; 

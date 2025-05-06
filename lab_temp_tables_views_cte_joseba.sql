# TEMPORARY TABLES, VIEWS AND CTES

# Challenge
# Creating a Customer Summary Report

# In this exercise, you will create a customer summary report that summarizes key information about customers 
# in the Sakila database, including their rental history and payment details. 
# The report will be generated using a combination of views, CTEs, and temporary tables.

USE sakila;

# Step 1: Create a View
# First, create a view that summarizes rental information for each customer. 
# The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW cust_rent_info AS
SELECT customer.customer_id, customer.first_name, customer.last_name, customer.email, COUNT(rental.rental_id) AS rental_count
FROM customer
INNER JOIN rental
USING (customer_id)
GROUP BY customer_id;

SELECT *
FROM cust_rent_info;

# Step 2: Create a Temporary Table
# Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
# The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
# and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE temp_total_paid AS
SELECT cri.customer_id, cri.first_name, cri.last_name, email, COUNT(rental_id) AS rental_count, SUM(payment.amount) AS total_paid
FROM cust_rent_info AS cri
INNER JOIN payment
USING (customer_id)
GROUP BY customer_id;

# Step 3: Create a CTE and the Customer Summary Report
# Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
# The CTE should include the customer's name, email address, rental count, and total amount paid.


WITH customer_summary AS (
    SELECT cri.first_name, cri.last_name, cri.email, cri.rental_count, ttp.total_paid
    FROM cust_rent_info AS cri
    INNER JOIN temp_total_paid AS ttp 
    USING (customer_id)
)
SELECT *
FROM customer_summary
ORDER BY total_paid DESC;

# Next, using the CTE, create the query to generate the final customer summary report, which should include: 
# customer name, email, rental_count, total_paid and average_payment_per_rental, 
# this last column is a derived column from total_paid and rental_count.

WITH customer_summary AS (
    SELECT cri.first_name, cri.last_name, cri.email, cri.rental_count, ttp.total_paid
    FROM cust_rent_info AS cri
    INNER JOIN temp_total_paid AS ttp 
    USING (customer_id)
)
SELECT 
    first_name, last_name, email, rental_count, total_paid,
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM customer_summary
ORDER BY total_paid DESC;

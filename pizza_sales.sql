use pizza_sales;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- Q1. Retrieve the total number of orders placed?
SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;
    
-- Q2. Calculate the total revenue generated from pizza sales?
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS revenue
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id;
    
-- Q3. Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Q4. Identify the most common pizza size ordered?
SELECT 
    p.size, COUNT(od.quantity) AS order_count
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- Q5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;

-- Q7. Determine the distribution of orders by hour of the day?
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour
ORDER BY order_count DESC;

-- Q8. Join relevant tables to find the category-wise distribution of pizzas?
SELECT 
    category, COUNT(name) AS pizza_name
FROM
    pizza_types
GROUP BY category
ORDER BY pizza_name DESC;

-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day?
SELECT 
    ROUND(AVG(quantity), 0) AS avg_num_of_pizzas_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity

-- Q10. Determine the top 3 most ordered pizza types based on revenue?
SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Q11. Calculate the percentage contribution of each pizza type to total revenue?
SELECT 
    pt.category,
    round((SUM(od.quantity * p.price) / (SELECT 
            SUM(od.quantity * p.price)
        FROM
            pizzas p
                JOIN
            order_details od ON p.pizza_id = od.pizza_id)) * 100,2) AS pct_contribution
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY pct_contribution DESC;

-- Q12. Analyze the cumulative revenue generated over time.
select
order_date, sum(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM
(SELECT 
    o.order_date, SUM(od.quantity * p.price) AS revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date) as sales;

-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, revenue
FROM
(SELECT category, name, revenue, RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rank_
FROM
(SELECT 
    pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category , pt.name) AS a) AS b
WHERE rank_ <= 3;






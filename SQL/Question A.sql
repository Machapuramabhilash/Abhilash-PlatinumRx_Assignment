/* 1 */
SELECT b.user_id, b.room_no
FROM bookings b
JOIN (
    SELECT user_id, MAX(booking_date) AS last_booking
    FROM bookings
    GROUP BY user_id
) lb
ON b.user_id = lb.user_id 
AND b.booking_date = lb.last_booking;

/* 2 */
SELECT bc.booking_id,
       SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 11 
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.booking_id;

/* 3 */
SELECT bc.bill_id,
       SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 10 
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;

/* 4 */
WITH item_orders AS (
    SELECT 
        MONTH(bc.bill_date) AS month,
        bc.item_id,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY MONTH(bc.bill_date), bc.item_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS rnk_desc,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS rnk_asc
    FROM item_orders
)
SELECT month, item_id, total_qty, 'MOST' AS type
FROM ranked
WHERE rnk_desc = 1

UNION ALL

SELECT month, item_id, total_qty, 'LEAST' AS type
FROM ranked
WHERE rnk_asc = 1;

/* 5 */
WITH monthly_bills AS (
    SELECT 
        MONTH(bc.bill_date) AS month,
        bc.bill_id,
        SUM(bc.item_quantity * i.item_rate) AS bill_amount
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY MONTH(bc.bill_date), bc.bill_id
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY bill_amount DESC) AS rnk
    FROM monthly_bills
)
SELECT month, bill_id, bill_amount
FROM ranked
WHERE rnk = 2;


/* 1 */
SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

/* 2 */
SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

/* 4 */
WITH clinic_profit AS (
    SELECT 
        c.city,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e 
        ON cs.cid = e.cid 
        AND MONTH(cs.datetime) = MONTH(e.datetime)
    WHERE MONTH(cs.datetime) = 9  -- example month
    GROUP BY c.city, cs.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM clinic_profit
)
SELECT *
FROM ranked
WHERE rnk = 1;

/* 5 */
WITH clinic_profit AS (
    SELECT 
        c.state,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e 
        ON cs.cid = e.cid 
        AND MONTH(cs.datetime) = MONTH(e.datetime)
    WHERE MONTH(cs.datetime) = 9
    GROUP BY c.state, cs.cid
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM clinic_profit
)
SELECT *
FROM ranked
WHERE rnk = 2;

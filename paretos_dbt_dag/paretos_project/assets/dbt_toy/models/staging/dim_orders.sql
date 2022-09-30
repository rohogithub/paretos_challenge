{{
    config( materialized= 'table' )
}}

with  fact_orders as(
    select *
    from {{ ref('stg_fact_orders')}}
)

SELECT order_date,
		sum(total_price) AS revenue,
		sum(total_sku_cost) AS total_sku_cost,
		sum(total_price - total_sku_cost) AS margin,
		count(order_date) AS numberOf_orders,		
		sum(total_price - total_price_without_tax) AS tax,
		sum( CASE WHEN total_price<=0 THEN 1 ELSE 0 END ) AS numberOf_invalid_total_price,
		sum( CASE WHEN total_sku_cost ISNULL THEN 1 ELSE 0 END ) AS numberOf_null_total_sku,
		sum( CASE WHEN margin<0 THEN 1 ELSE 0 END ) AS numberOf_negetive_margin,
		sum( CASE WHEN margin<0 THEN margin ELSE 0 END ) AS sum_negetive_margin
FROM fact_orders
GROUP BY 1
ORDER BY 1
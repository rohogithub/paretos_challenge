with  SKU_cost as(
    select *
    from {{ ref('stg_SKU_cost')}}
),
orders as(
    select *
    from {{ ref('stg_orders')}}
),
orders_items as(
    select *
    from {{ ref('stg_orders_items')}}
)

SELECT orders._airbyte_orders_hashid AS order_id,
	orders.created_at AS order_date,
	orders.total_price,
	orders.total_price_without_tax,
	sum( CAST(orders_items.orders_line_items_quantity * SKU_cost.netto_cost  as real)) AS total_sku_cost,
	sum(orders_items.orders_line_items_price) AS sum_orders_line_items_price,
	orders.total_price - sum( CAST(orders_items.orders_line_items_quantity * SKU_cost.netto_cost as real)) AS margin
FROM orders
	LEFT JOIN orders_items ON orders._airbyte_orders_hashid = orders_items._airbyte_orders_hashid
	LEFT JOIN SKU_cost ON orders_items.sku = SKU_cost.sku
GROUP BY orders._airbyte_orders_hashid, orders.created_at, orders.total_price, orders.total_price_without_tax

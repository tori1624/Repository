select a.product_id
     , b.product_name
     , (sum(a.amount) * avg(b.price)) as total_sales
from food_order a
join food_product b on a.product_id = b.product_id
where to_char(a.produce_date, 'yyyy-mm') = '2022-05'
group by a.product_id, b.product_name
order by total_sales desc, a.product_id asc
;

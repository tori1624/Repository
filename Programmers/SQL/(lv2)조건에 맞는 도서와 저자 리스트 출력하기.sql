select a.book_id
     , b.author_name
     , to_char(a.published_date, 'yyyy-mm-dd') as published_date
from book a
join author b on a.author_id = b.author_id
where a.category = '경제'
order by a.published_date
;

select flavor
-- 합친 데이터로부터 주문량 합계 게산 후 정렬
from (select flavor, sum(total_order) as sum_order
      --상반기와 7월 데이터 합치기
      from (select * from first_half
            union all
            select * from july
           )
      group by flavor
      order by sum_order desc)
where rownum <= 3 -- limit을 통해 상위 3개 맛 추출
;

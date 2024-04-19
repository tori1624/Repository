SELECT B.MEMBER_NAME
     , A.REVIEW_TEXT
     , TO_CHAR(A.REVIEW_DATE, 'YYYY-MM-DD') AS REVIEW_DATE
FROM REST_REVIEW A
JOIN MEMBER_PROFILE B ON A.MEMBER_ID = B.MEMBER_ID
--리뷰 수를 바탕으로 리뷰를 가장 많이 작성한 회원 ID 추출
WHERE A.MEMBER_ID IN (SELECT MEMBER_ID
                      FROM REST_REVIEW
                      GROUP BY MEMBER_ID
                      --가장 많이 작성한 리뷰의 수
                      HAVING COUNT(MEMBER_ID) = (SELECT MAX(COUNT(MEMBER_ID))
                                                 FROM REST_REVIEW
                                                 GROUP BY MEMBER_ID
                                                )
                     )
ORDER BY REVIEW_DATE, REVIEW_TEXT
;

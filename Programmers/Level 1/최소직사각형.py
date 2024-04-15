def solution(sizes):
    
    max_w = 0
    max_h = 0
    
    for size in sizes:
        # 명함을 가로로 눕히는 경우 고려
        if size[0] < size[1]:
            tmp_w = size[1]
            tmp_h = size[0]
        else:
            tmp_w = size[0]
            tmp_h = size[1]

        # 폭과 높이의 최댓값 업데이트
        if tmp_w > max_w:
            max_w = tmp_w
        
        if tmp_h > max_h:
            max_h = tmp_h
        
    answer = max_w * max_h
    return answer

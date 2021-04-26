def solution(d, budget):
    if sum(d) <= budget:
        answer = len(d)
    else:
        while sum(d) > budget:
            d = sorted(d)
            d.pop(-1)
            answer = len(d)
        
    return answer

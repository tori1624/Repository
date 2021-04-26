def solution(citations):
    answer = 1
    while True:
        count = 0
        for i in range(len(citations)):
            if citations[i] >= answer: count += 1
        if answer > count: break
        answer += 1

    return answer-1

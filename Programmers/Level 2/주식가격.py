def solution(prices):
    answer = []

    for i in range(len(prices)-1):
        sec = 1
        price = prices[i]
        j = i+1
        while j < len(prices)-1:
            if price <= prices[j]:
                sec += 1
            else:
                break
            j += 1
        answer.append(sec)
    answer.append(0)

    return answer

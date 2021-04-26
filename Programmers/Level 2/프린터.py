def solution(priorities, location):
    result = []
    tmp = [[priorities[i], list(range(len(priorities)))[i]] for i in range(len(priorities))]
    i = 0
    while True:
        if tmp[i][0] == max(priorities):
            result.append(tmp[i])
            priorities[i] = 0
        if sum(priorities) == 0:
            break
        i += 1
        if i == len(tmp): i = 0
            
    for i in range(len(result)):
        if result[i][1] == location: answer = i+1

    return answer

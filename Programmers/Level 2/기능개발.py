def solution(progresses, speeds):
    answer = []
    count = []

    for i, j in zip(progresses, speeds):
        tmp = 0
        while i < 100:
            i += j
            tmp += 1
        count.append(tmp)

    standard = count[0]
    tmp = 1
    for i in range(1, len(count)):
        if standard >= count[i]:
            tmp += 1
        else:
            answer.append(tmp)
            tmp = 1
            standard = count[i]
    answer.append(tmp)

    return answer

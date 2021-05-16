def solution(skill, skill_trees):
    answer = 0

    for i in skill_trees:
        tmp = []
        for j in skill:
            if j in i:
                tmp.append(i.index(j))
            else:
                tmp.append(len(i))

        k = 1
        while k < len(tmp):
            if tmp[k-1] > tmp[k]:
                break
            k += 1

        if k == len(tmp):
            answer += 1

    return answer

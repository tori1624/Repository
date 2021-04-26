def solution(N, stages):
    fail = []
    answer = []
    num_user = len(stages)
    
    for i in range(1, N+1):
        if num_user == 0:
            fail.append(0)
        else:
            fail.append(stages.count(i)/num_user)
            num_user -= stages.count(i)
    
    order = sorted(fail, reverse = True)
    
    for j in order:
        answer.append(fail.index(j)+1)
        fail[fail.index(j)] = 2
    
    return answer

def solution(dartResult):
    answer = [0]
    
    for i in dartResult:
        # score
        if i.isdigit():
            answer.append(int(i))
            if answer[-1] == 0 and answer[-2] == 1:
                answer[-2] = 10
                answer.pop(-1)
            
        # bonus
        elif i.isalpha():
            if i == 'S':
                answer[-1] = answer[-1] ** 1
            elif i == 'D':
                answer[-1] = answer[-1] ** 2
            elif i == 'T':
                answer[-1] = answer[-1] ** 3
                
        # option
        elif i == '*':
            if len(answer) == 1:
                answer[-1] = answer[-1] * 2
            else:
                answer[-1] = answer[-1] * 2
                answer[-2] = answer[-2] * 2
        elif i == '#':
            answer[-1] = answer[-1] * -1
    
    return sum(answer)

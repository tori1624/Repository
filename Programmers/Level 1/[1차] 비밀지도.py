def solution(n, arr1, arr2):
    answer = []
    arr1_list = []; arr2_list = []
    
    for i in arr1:
        tmp = format(i, 'b')
        while len(tmp) < n:
            tmp = ''.join(['0', tmp])
        arr1_list.append(tmp)
        
    for i in arr2:
        tmp = format(i, 'b')
        while len(tmp) < n:
            tmp = ''.join(['0', tmp])
        arr2_list.append(tmp)
    
    for i in range(n):
        tmp = []
        for j in range(n):
            if (int(arr1_list[i][j])+int(arr2_list[i][j])) > 0: tmp += '#'
            else: tmp += ' '
        answer.append(''.join(tmp))
    
    return answer

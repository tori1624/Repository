# 정답
def solution(numbers):
    str_nums = list(map(str, numbers))
    str_nums.sort(key = lambda x : x*3, reverse = True)
    
    return str(int(''.join(str_nums)))

# 시간 초과 정답
from itertools import permutations

def solution(numbers):
    str_nums = list(map(str, numbers))
    combi = list(map(''.join, list(permutations(str_nums, len(str_nums)))))
    answer = max(list(map(int, combi)))
    
    return str(answer)

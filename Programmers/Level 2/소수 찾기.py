from itertools import permutations

def prime(n):
    if n < 2:
        return False

    for i in range(2, n):
        if n % i == 0: return False

    return True

def solution(numbers):
    answer = []
    for j in range(1, len(numbers)+1):
        tmp = set(list(map(''.join, permutations(list(numbers), j))))
        for k in list(tmp):
            if prime(int(k)):
                answer.append(int(k))

    return len(set(answer))

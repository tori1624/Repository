def solution(lottos, win_nums):
    rank = [6, 5, 4, 3, 2, 1]
    
    min = sum([1 if i in win_nums else 0 for i in lottos])
    max = min + lottos.count(0)
    
    if min == 0: min = 1
    if max == 0: max = 1
    
    return [rank.index(max)+1, rank.index(min)+1]

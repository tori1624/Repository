from itertools import permutations

def solution(k, dungeons):

    # permutation 함수를 통해 모든 케이스 구하기 (던전의 최대 길이가 8)
    all_cases = []
    for case in permutations(dungeons, len(dungeons)):
        all_cases.append(list(case))

    # 각 케이스별로 몇 개의 던전을 탐험할 수 있는지 계산
    cnt_list = []
    for i in range(len(all_cases)):
        hp = k # 피로도를 초기화하는 것이 중요
        cnt = 0
        for dungeon in all_cases[i]:
            if hp >= dungeon[0]:
                hp = hp - dungeon[1]
                cnt += 1
            elif hp < dungeon[0]:
                break
                
        cnt_list.append(cnt)

    answer = max(cnt_list)      
    return answer

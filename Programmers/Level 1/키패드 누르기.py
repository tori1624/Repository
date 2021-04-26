def solution(numbers, hand):
    import math
    
    answer = []
    keypad = {1: [0, 3], 2: [1, 3], 3: [2, 3], 
             4: [0, 2], 5: [1, 2], 6: [2, 2],
             7: [0, 1], 8: [1, 1], 9: [2, 1],
             '*': [0, 0], 0: [1, 0], '#': [2, 0]}
    L = keypad['*']; R = keypad['#']
    
    for i in numbers:
        # 숫자가 2, 5, 8, 0일 경우
        if i % 3 == 2 or i == 0:
            ld = abs(L[0]-keypad[i][0])+abs(L[1]-keypad[i][1])
            rd = abs(R[0]-keypad[i][0])+abs(R[1]-keypad[i][1])
            if ld == rd:
                answer.append(hand[0].upper())
                if hand[0] == 'l': L = keypad[i]
                else: R = keypad[i]
            elif ld < rd:
                answer.append('L'); L = keypad[i]
            else:
                answer.append('R'); R = keypad[i]    
        # 숫자가 1, 4, 7일 경우
        elif i % 3 == 1:
            answer.append('L'); L = keypad[i]
        # 숫자가 3, 6, 9일 경우
        else:
            answer.append('R'); R = keypad[i]      
    
    return ''.join(answer)

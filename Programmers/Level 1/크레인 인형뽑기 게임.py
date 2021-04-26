def solution(board, moves):
    answer = 0
    out = [0]
    
    for i in moves:
        j = 0
        while j < len(board):
            if board[j][i-1] != 0:
                out.append(board[j][i-1])
                if out[-1] == out[-2]:
                    del out[-2:]
                    answer += 2
                board[j][i-1] = 0
                break
            j += 1
    return answer

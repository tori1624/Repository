import heapq

def solution(scoville, K):
    answer = 0
    heapq.heapify(scoville)
    while scoville[0] < K:
        tmp = heapq.heappop(scoville)+(heapq.heappop(scoville)*2)
        heapq.heappush(scoville, tmp)
        if len(scoville) == 1 and scoville[0] < K:
            answer = -1
            break
        answer += 1    
        
    return answer

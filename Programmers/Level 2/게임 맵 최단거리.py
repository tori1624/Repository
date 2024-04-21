# 동빈나 이코테 유튜브 참고 (https://www.youtube.com/watch?v=7C9RgOcvkvo)
from collections import deque

def solution(maps):
    # 이동할 네 가지 방향 (상, 하, 좌, 우)
    dx = [-1, 1, 0, 0]
    dy = [0, 0, -1, 1]
    
    # BFS
    def bfs(x, y, graph):
        n = len(graph)
        m = len(graph[0])
        
        # 큐(queue) 구현을 위해 deque 라이브러리 사용
        queue = deque()
        queue.append((x, y))

        # 큐가 빌 때까지 반복하기
        while queue:
            x, y = queue.popleft()
            # 현재 위치에서 4가지 방향으로의 위치 확인
            for i in range(4):
                nx = x + dx[i]
                ny = y + dy[i]
                # 맵을 벗어나는 경우 무시
                if nx < 0 or nx >= n or ny <0 or ny >= m:
                    continue
                # 벽인 경우 무시
                if graph[nx][ny] == 0:
                    continue
                # 해당 노드를 처음 방문하는 경우에만 최단 거리 기록
                if graph[nx][ny] == 1:
                    graph[nx][ny] = graph[x][y] + 1
                    queue.append((nx, ny))

        # 가장 오른쪽 아래까지의 최단 거리 반환
        if graph[n-1][m-1] > 1:
            result = graph[n-1][m-1]
        elif graph[n-1][m-1] == 1:
            result = -1
        
        return result
    
    answer = bfs(0, 0, maps)

    return answer

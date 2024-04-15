def solution(brown, yellow):
  # brown과 yellow의 최솟값을 고려했을 때, a의 최솟값은 3  
  a = 3

  # 1) brown+yellow = a*b
  # 2) yellow = (a-2)*(b-2)
  # 위 두 식을 통해 아래의 b를 도출
  while True:
      b = brown/2+2-a
      if (a-2)*(b-2) == yellow:
          break
      a += 1

  # a는 b보다 같거나 큼
  answer=[max(a, b), min(a, b)]
  return answer

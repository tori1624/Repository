## 1) [5585] 거스름돈 문제
# 타로는 자주 JOI잡화점에서 물건을 산다. JOI잡화점에는 잔돈으로 500엔, 100엔, 50엔, 10엔, 5엔, 1엔이 충분히 있고, 언제나 거스름돈 개수가 가장 적게 잔돈을 준다.
# 타로가 JOI잡화점에서 물건을 사고 카운터에서 1000엔 지폐를 한장 냈을 때, 받을 잔돈에 포함된 잔돈의 개수를 구하는 프로그램을 작성하시오.

money = int(input())

coins = [500, 100, 50, 10, 5, 1]
change = 1000 - money
count = 0

for coin in coins:
    count += change // coin
    change %= coin
    
print(count)


## 2) [2839] 설탕 배달
# 상근이는 요즘 설탕공장에서 설탕을 배달하고 있다. 상근이는 지금 사탕가게에 설탕을 정확하게 N킬로그램을 배달해야 한다. 설탕공장에서 만드는 설탕은 봉지에 담겨져 있다.
# 봉지는 3킬로그램 봉지와 5킬로그램 봉지가 있다.
# 상근이는 귀찮기 때문에, 최대한 적은 봉지를 들고 가려고 한다. 예를 들어, 18킬로그램 설탕을 배달해야 할 때, 3킬로그램 봉지 6개를 가져가도 되지만, 5킬로그램 3개와 3킬로그램 1개를 배달하면, 더 적은 개수의 봉지를 배달할 수 있다.
# 상근이가 설탕을 정확하게 N킬로그램 배달해야 할 때, 봉지 몇 개를 가져가면 되는지 그 수를 구하는 프로그램을 작성하시오.

sugar = int(input())

count = 0
while sugar >= 0:
    if sugar % 5 == 0:
        count += sugar // 5
        break
    sugar -= 3
    count += 1
else:
    count = -1
    
print(count)


# 3) [11399 ]ATM
# 인하은행에는 ATM이 1대밖에 없다. 지금 이 ATM앞에 N명의 사람들이 줄을 서있다. 사람은 1번부터 N번까지 번호가 매겨져 있으며, i번 사람이 돈을 인출하는데 걸리는 시간은 Pi분이다.
# 사람들이 줄을 서는 순서에 따라서, 돈을 인출하는데 필요한 시간의 합이 달라지게 된다. 예를 들어, 총 5명이 있고, P1 = 3, P2 = 1, P3 = 4, P4 = 3, P5 = 2 인 경우를 생각해보자. 
# [1, 2, 3, 4, 5] 순서로 줄을 선다면, 1번 사람은 3분만에 돈을 뽑을 수 있다. 2번 사람은 1번 사람이 돈을 뽑을 때 까지 기다려야 하기 때문에, 3+1 = 4분이 걸리게 된다. 
# 3번 사람은 1번, 2번 사람이 돈을 뽑을 때까지 기다려야 하기 때문에, 총 3+1+4 = 8분이 필요하게 된다. 4번 사람은 3+1+4+3 = 11분, 5번 사람은 3+1+4+3+2 = 13분이 걸리게 된다. 
# 이 경우에 각 사람이 돈을 인출하는데 필요한 시간의 합은 3+4+8+11+13 = 39분이 된다.
# 줄을 [2, 5, 1, 4, 3] 순서로 줄을 서면, 2번 사람은 1분만에, 5번 사람은 1+2 = 3분, 1번 사람은 1+2+3 = 6분, 4번 사람은 1+2+3+3 = 9분, 3번 사람은 1+2+3+3+4 = 13분이 걸리게 된다. 
# 각 사람이 돈을 인출하는데 필요한 시간의 합은 1+3+6+9+13 = 32분이다. 이 방법보다 더 필요한 시간의 합을 최소로 만들 수는 없다.
# 줄을 서 있는 사람의 수 N과 각 사람이 돈을 인출하는데 걸리는 시간 Pi가 주어졌을 때, 각 사람이 돈을 인출하는데 필요한 시간의 합의 최솟값을 구하는 프로그램을 작성하시오.

n = int(input())
data = list(map(int, input().split()))
data.sort()

time_per = 0
time_total = 0

for i in range(len(data)):
    time_per += data[i]
    time_total += time_per

print(time_total)


## 4) [11047] 동전 0
# 준규가 가지고 있는 동전은 총 N종류이고, 각각의 동전을 매우 많이 가지고 있다. 동전을 적절히 사용해서 그 가치의 합을 K로 만들려고 한다. 
# 이때 필요한 동전 개수의 최솟값을 구하는 프로그램을 작성하시오.

n, k = map(int, input().split())
coin_list = []
for i in range(n):
    coin_list.append(int(input()))
    
count = 0
for i in reversed(range(n)):
    count += k // coin_list[i]
    k %= coin_list[i]
    
print(count)


## 5) [1026] 보물
# 옛날 옛적에 수학이 항상 큰 골칫거리였던 나라가 있었다. 이 나라의 국왕 김지민은 다음과 같은 문제를 내고 큰 상금을 걸었다.
# 길이가 N인 정수 배열 A와 B가 있다. 다음과 같이 함수 S를 정의하자.
# S = A[0] × B[0] + ... + A[N-1] × B[N-1]
# S의 값을 가장 작게 만들기 위해 A의 수를 재배열하자. 단, B에 있는 수는 재배열하면 안 된다.
# S의 최솟값을 출력하는 프로그램을 작성하시오.

n = int(input())
A = list(map(int, input().split()))
B = list(map(int, input().split()))

A.sort()
B.sort(reverse=True)

result = 0
for i in range(n):
    result += (A[i] * B[i])
    
print(result)

## 6) [2864] 5와6의 차이
# 상근이는 2863번에서 표를 너무 열심히 돌린 나머지 5와 6을 헷갈리기 시작했다.
# 상근이가 숫자 5를 볼 때, 5로 볼 때도 있지만, 6으로 잘못 볼 수도 있고, 6을 볼 때는, 6으로 볼 때도 있지만, 5로 잘못 볼 수도 있다.
# 두 수 A와 B가 주어졌을 때, 상근이는 이 두 수를 더하려고 한다. 이때, 상근이가 구할 수 있는 두 수의 가능한 합 중, 최솟값과 최댓값을 구해 출력하는 프로그램을 작성하시오.

a, b = map(str, input().split())

min = int(a.replace('6', '5')) + int(b.replace('6', '5'))
max = int(a.replace('5', '6')) + int(b.replace('5', '6'))

print(min, max)

## 7) [1541] 잃어버린 괄호
# 세준이는 양수와 +, -, 그리고 괄호를 가지고 식을 만들었다. 그리고 나서 세준이는 괄호를 모두 지웠다.
# 그리고 나서 세준이는 괄호를 적절히 쳐서 이 식의 값을 최소로 만들려고 한다.
# 괄호를 적절히 쳐서 이 식의 값을 최소로 만드는 프로그램을 작성하시오.

nums = input().split('-')

result = 0

for i in nums[0].split('+'):
  result += int(i)

for i in nums[1:]:
  for j in i.split('+'):
    result -= int(j)

print(result)

## 8) [10162] 전자레인지
# 3개의 시간조절용 버튼 A B C가 달린 전자레인지가 있다. 각 버튼마다 일정한 시간이 지정되어 있어 해당 버튼을 한번 누를 때마다 그 시간이 동작시간에 더해진다. 
# 버튼 A, B, C에 지정된 시간은 각각 5분, 1분, 10초이다.
# 냉동음식마다 전자레인지로 요리해야할 시간 T가 초단위로 표시되어 있다. 우리는 A, B, C 3개의 버튼을 적절히 눌러서 그 시간의 합이 정확히 T초가 되도록 해야 한다. 
# 단 버튼 A, B, C를 누른 횟수의 합은 항상 최소가 되어야 한다. 이것을 최소버튼 조작이라고 한다. 
# 만일 요리시간이 100초라고 하면(T=100) B를 1번, C는 4번 누르면 된다. 이와 다르게 C를 10번 눌러도 100초가 되지만 이 경우 10번은 최소 횟수가 아니기 때문이 답이 될 수 없다. 
# 이 경우 B 1번, C 4번, 총 5번이 최소버튼 조작이다. 그리고 T=234와 같이 3개의 버튼으로 시간을 정확히 맞출 수 없는 경우도 있다. 
# 여러분은 주어진 요리시간 T초를 맞추기 위한 최소버튼 조작 방법을 구하는 프로그램을 작성해야 한다.

time = int(input())
buttons = [300, 60, 10]
result = [0, 0, 0]

if time % 10 == 0:
  for i in range(len(buttons)):
    result[i] += time // buttons[i]
    time %= buttons[i]
      
  print(result[0], result[1], result[2])
  
else:
  print(-1)
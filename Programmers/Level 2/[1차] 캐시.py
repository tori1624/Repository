def solution(cacheSize, cities):
    answer = 0
    cache = []

    for i in cities:
        i = i.lower()
        if i not in cache:
            answer += 5
            cache.append(i)
            if len(cache) > cacheSize:
                cache.pop(0)
        else:
            answer += 1
            cache.pop(cache.index(i))
            cache.append(i)     

    return answer

def solution(phone_book):
    answer = True
    phone_book.sort()
    for i,j in zip(phone_book, phone_book [1:]):
        if (i == j[:len(i)]):
            return False
    return answer

def solution(new_id):
    answer = ''
    # step1
    new_id = new_id.lower()
    # step2
    for i in new_id:
        if i.isalpha() or i.isdigit() or i in ['-', '_', '.']:
            answer += i
    # step3
    while '..' in answer:
        answer = answer.replace('..', '.')
    # step4
    answer = answer.strip('.')
    # step5
    if len(answer) == 0: answer = 'a'
    # step6
    if len(answer) >= 16: answer = answer[:15].strip('.')
    # step7
    while len(answer) <= 2:
        answer += answer[-1]
            
    return answer

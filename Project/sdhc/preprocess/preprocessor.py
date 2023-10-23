######################################################
#    프로그램명    : preprocessor.py
#    작성자        : Youngho Lee
#    작성일자      : 2023.04.06
#    파라미터      : None
#    설명          : 전처리 관련 공통 모듈
######################################################

import re
import numpy as np

class Preprocessor:
    
    def remove_outlier(self, value):
        """
        검사 내역 이상치(글자 및 특수문자) 제거 함수

        <param>
        value : 검사 내역
        """
        
        val = str(value)

        # float으로 변경하기 전, '.'으로 시작하는 끝나는 값 처리
        val = val.strip('.')

        # ','를 '.'으로 변환
        val = val.replace(',,', '.').replace(',', '.')

        try:
            val = float(val)

        except:
            # string이 긴 경우
            if len(re.sub(r'[0-9\s\-\~]', '', val)) > 2:
                return np.nan

            # '>'을 포함하는 경우
            if '>' in val and re.sub(r'[^0-9]', '', val).isdigit():
                val = float(val.split('>')[-1])
                return val

            # 검사 결과가 범위로 입력된 경우
            if '-' in val and re.sub(r'[^0-9]', '', val).isdigit():
                val = re.sub(r'[^0-9\-]', '', val)
                val = np.mean(np.array(val.split('-')).astype(float))
                return val 
            elif '~' in val and re.sub(r'[^0-9]', '', val).isdigit():
                val = re.sub(r'[^0-9\~]', '', val)
                val = np.mean(np.array(val.split('~')).astype(float))
                return val

            # 숫자를 제외한 문자 제거
            val = re.sub(r'[^0-9]', '', val)

            if val == '':
                val = np.nan

        return float(val)

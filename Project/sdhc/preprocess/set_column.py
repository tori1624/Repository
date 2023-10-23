######################################################
#    프로그램명    : set_column.py
#    작성자        : Youngho Lee
#    작성일자      : 2023.02.10
#    파라미터      : None
#    설명          : DB로부터 테이블 로드 시, 분석에 필요한 컬럼 설정
######################################################

import os
import sys
import json

# path
wd = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
del sys.path[0]
sys.path.insert(0, wd)
os.chdir(wd)


class SetColumn():

    def __init__(self):

        # 테이블 설명과 테이블명 매칭
        self.table_list = {
                           {table korean name}: {table name},
                           ...
                          }

        # 테이블별 필수 컬럼
        self.basic_column = {
                             {table korean name}: {columns},
                             ...
                            }

        self.sort_column = {
                            {table korean name}: {sort columns},
                            ...
                           }

        # 컬럼명 정리된 json 파일 위치 경로
        self.json_path = f'{wd}/utils/column/'


    def extract_column(self, table_name):

        # 필수 컬럼 추출
        column_list = self.basic_column.get(table_name).copy()

        # 테이블별 변수 컬럼 추출
        if {io_table} in table_name:
            tmp_column = {}
        else:
            with open(self.json_path + self.table_list.get(table_name) + '.json') as f:
                tmp_column = json.load(f)

        # 필수 및 변수 컬럼 병합
        column_list.extend(list(tmp_column.values()))
        column_list = str(column_list).replace("'", "").replace("[", "").replace("]", "")

        return column_list

import os
import time
import pandas as pd
import numpy as np
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.select import Select

# 크롬 드라이버 옵션
options = webdriver.ChromeOptions()
options.add_argument('headless')

# 크롬 드라이버 및 웹페이지 실행
driver = webdriver.Chrome(options=options)
driver.get('https://www.courtauction.go.kr/pgj/index.on')
time.sleep(3)

# 물건 상세 검색 이동
driver.find_element(By.XPATH, '//*[@id="mf_wq_uuid_260"]').click()

# 법원 목록 가져오기
court_list = driver.find_elements(By.XPATH, '//*[@id="mf_wfm_mainFrame_sbx_rletCortOfc"]/option')
courts = list(map(lambda x: x.text, court_list))[1:]

# 법원 지정
setCourt = Select(driver.find_element(By.ID, 'mf_wfm_mainFrame_sbx_rletCortOfc'))
setCourt.select_by_visible_text(courts[0])
driver.find_element(By.XPATH, '//*[@id="mf_wfm_mainFrame_btn_gdsDtlSrch"]').click()

# 법원별 물건 및 정보 가져오기
rows = driver.find_elements(By.XPATH, '//table[@id="mf_wfm_mainFrame_grd_gdsDtlSrchResult_body_table"]/tbody/tr')

merged_data = []

for i in range(0, len(rows), 2):
    upper_cells = rows[i].find_elements(By.TAG_NAME, "td")
    upper_data = [cell.text.strip() for cell in upper_cells]

    if i+1 < len(rows):
        lower_cells = rows[i+1].find_elements(By.TAG_NAME, "td")
        lower_data = [cell.text.strip() for cell in lower_cells]
    else:
        lower_data = []

    merged_row = upper_data + lower_data
    merged_data.append(merged_row)

columns = [
    'case_no(total)', 'case_no(line)', 'item_no', 'address/info', 'map', 'remarks', 'appraisal_price',
    'court_div/sale_date', 'usage', 'min_bid_price', 'status'
]

df = pd.DataFrame(merged_data, columns=columns)

# 추가 전처리
df['court'] = df['case_no(line)'].str.split('\n').str[0] # 법원
df['address'] = df['address/info'].str.split('\n').str[0] # 소재지
df['info'] = df['address/info'].str.split('[').str[1].str[:-1] # 내역
df['court_div'] = df['court_div/sale_date'].str.split('\n').str[0] # 담당계
df['sale_date'] = df['court_div/sale_date'].str.split('\n').str[1] # 매각기일

# 상세 링크 접속 정보를 위한 전처리
df['case_no'] = df['case_no(line)'].str.split('\n').str[1]
df['search_year'] = df['case_no'].str.split('타경').str[0]
df['search_no'] = df['case_no'].str.split('타경').str[1]

sorted_df = df[['court', 'case_no(line)', 'item_no', 'usage', 'address', 'info', 'remarks', 'appraisal_price',
                'min_bid_price', 'court_div', 'sale_date', 'status', 'search_year', 'search_no']]

# 결측치 대체
cols_to_fill = sorted_df.columns.difference(['remarks', 'search_year', 'search_no'])

for col in cols_to_fill:
    sorted_df[col] = sorted_df[col].replace('', np.nan)  # 빈 문자열을 NaN으로
    sorted_df[col] = sorted_df[col][::-1].bfill()[::-1]  # 아래쪽 값으로 채움

# len(driver.find_elements(By.XPATH, '//ul[@class="w2pageList_ul"]/li'))
# //*[@id="mf_wfm_mainFrame_pgl_gdsDtlSrchPage_next_btn"]

driver.quit()

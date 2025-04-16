import os
import time
import pandas as pd
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

# 법원별 물건 가져오기
test = driver.find_elements(By.XPATH, '//*[@id="mf_wfm_mainFrame_grd_gdsDtlSrchResult_cell_0_1"]/nobr')
list(map(lambda x: x.text, test))

driver.quit()

# 2021 Weather Big Data Contest

### 기상청 **[<2021 날씨 빅데이터 콘테스트 - 민간협력형>](https://bd.kma.go.kr/contest/info_05.do)**
### **장려상 수상작 (Unnormal)**   
**날씨에 따른 온라인 구매 예측 - VARX 모델에 기반한 분석 모델 제안**  



<br>




### **공모 배경**

---

<img src = "https://s3.us-west-2.amazonaws.com/secure.notion-static.com/1fa17323-7d9e-4c15-896a-577f3b901255/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220802%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220802T014333Z&X-Amz-Expires=86400&X-Amz-Signature=bd8a0612a51d02d7bfdfb6b8819f655425e0b6ab0c98fd15a3abc1956b7a5494&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject">


* 기상·기후 정보와 SNS 채널을 활용한 소비패턴 파악과 예측의 정확성 제고 및 마케팅 효과의 극대화



<br>
<br>

### **주요 분석 과정**
----

<img src = "https://s3.us-west-2.amazonaws.com/secure.notion-static.com/0cebc759-ddec-48cb-b85f-abd8324ed7b7/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220802%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220802T051743Z&X-Amz-Expires=86400&X-Amz-Signature=7e07bef23134486903db07a3c9eb043a73a64778f9cb7e64706ed61ae987005a&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject">


<br>

**[데이터 정제]**
- 기상 데이터 결측값을 MICE를 이용해 처리하여 MAR로 가정된 결측값 대체
- 온라인 구매건수 없는 날짜, 성별, 연령대별 결측값 0(개)로 처리




**[EDA]**
- 상품 대분류별 구매량 그래프에서 계절성을 보이므로 제품 구매는 날씨에 영향 받을 것으로 확인
- t-test와 ANOVA 검정을 통해 성별/연령대별 구매건수 평균 차이 유의함을 확인
- 연령대별 구매 카테고리 워드클라우드로 성별/연령대별 카테고리 상이함을 확인



**[데이터 전처리]**




- 카테고리 재분류
    - 카테고리의 명확한 기준 재설정 & 식품 중분류 추가 (식품 공전, 랄라블라, LG생활전자 분류 기준 참고)
    - 식품, 냉난방가전, 뷰티 카테고리의 소분류 균형

- 날씨지수 생성
    - 지역정보 활용 불가능한 온라인 구매내역/소셜 데이터와 지역정보가 필수인 날씨 데이터 동시 활용 목표
    - PCA를 통해 일별 대표 날씨 지수(기온, 풍속, 미세먼지, 습도&강수) 생성


- 표준화
    - 분류별 구매량 표준화


- 제품군 군집화
    - 날씨에 큰 영향 받지 않는 카테고리 제거 (= 구매량의 변동폭이 작은 제품 제거)
    - 식품(k=4), 뷰티(k=3), 냉난방가전(k=3) 각 분류별 변동폭 가장 작은 군집 날씨 영향 없다고 판단 후 제외

- 다중회귀분석
    - 제품군별 구매에 영향 미치는 날씨 변수 도출 및 소셜데이터의 영향력 검정
    - 제품군별 다중회귀모형 적용, 단계별 변수선택으로 영향이 유의한 날씨/소셜 변수 선택, VIF로 다중공선성 확인


**[소비 트랜드 분석]**

- 날씨에 민감한 제품군 주 소비층은 3, 40대
- 남성보다는 여성의 SNS 이용 비율 높으며 2, 3, 40대가 전체 SNS 이용 비율의 약 70% 차지
- 날씨에 민감한 제품군과 SNS 문서 건수간의 경향성 확인
- SNS 데이터와 온라인 구매건수의 긍정적/부정적 연관성 확인

 **[예측 모델]**

- **VARX**
    1. 사용하는 모든 변수의 시계열성 고려해 **시계열 모델** 선택
    2. 날씨 변수들을 외생변수로 활용 가능해야 하므로 ARIMAX 등 **외생변수 포함 모델** 선택
    3. 다수의 제품군 사이 연관성 존재하므로 **다변량 반응변수 고려 가능 모델** 선택 
    * **VARX(2, 4)** 예측 모델 선택

- 시계열 모델 예측의 대표적 방법 Rolling Walk Forward 이용해 날씨에 따른 수요 예측

- 예측 오차(RMSE) 비교
    - **VARX** > ARIMAX > Linear Regression > Random Forest
    - 시계열 모델(VARX, ARIMAX)의 예측 오차가 더 낮음
    - 시계열 모델 중 다변량 상관관계를 고려한 VARX의 예측 오차가 더 낮음


<br><br>


### **결과 활용방안 및 제안**
---

<img src = "https://s3.us-west-2.amazonaws.com/secure.notion-static.com/77d1433b-a61b-4ccf-9a73-0f2475302c69/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220802%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220802T052751Z&X-Amz-Expires=86400&X-Amz-Signature=a2fce0e6ce51297e840b194a27c61e651f57d6410b6462c690aa7e5c7b721755&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject">


- 브랜드의 세부 제품의 구매량 한 번에 고려하여 수요 예측 가능


- SNS & 날씨 마케팅
    - 날씨에 따른 수요 예측으로 적절한 시기에 주 소비층을 타겟팅하여 홍보에 적절한 SNS 플랫폼 선택 

- SNS 활용 전략
    - 날씨데이터 + VARX 모델 = 주간 상품 구매 예측 활용
    - 구매 유도하고자 하는 제품에 대한 레시피 및 상품 판매 사이트 함께 제안
    - 상품에 대한 관심도 증가와 함께 구매 전환으로 이어질 것을 기대

- 장바구니 전략
    - 장바구니에 상품 담아 둔 잠재고객에게 날씨의 영향으로 잘 소비되지 않는 제품 쿠폰 제공
    - 날씨로 인해 구매량이 저조할 것으로 예상되는 상품의 효율적 구매 전환 기대


<br>
<br>

### **활용 데이터 목록**
---

**2018-01-01 \~ 2019-12-31**  

**[기상청 날씨마루]**
- 기온
    - 지역별 평균, 최고, 최저 기온
- 강수량
    - 지역별 총 강수량, 최저 강수량
- 습도
    - 지역별 평균 상대습도
- 풍속
    - 지역별 평균 풍속
- 미세먼지
    - 지역별 미세먼지, 초미세먼지 농도

**[(주)엠코퍼레이션]**  
- 온라인 구매이력
    - 날짜, 성별, 나이, 상품 대분류명, 상품 소분류명, 구매 수량

**[(주)바이브컴퍼니]**  
- 소셜 데이터
    - 날짜, 상품 대분류명, 상품 소분류명, 10만 건 당 문서 건수


<br>

### **사용 툴**
---
- **R**





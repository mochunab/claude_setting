# 범용 Google Analytics 4 전략서

> 어떤 웹 프로젝트에든 적용 가능한 GA4 설정, 이벤트 설계, 퍼널 분석 가이드
> 최종 업데이트: 2026-04-03

---

## 1. GA4 초기 설정

### 1.1 기본 구현

| 항목 | 설명 |
|------|------|
| 측정 ID | 환경변수로 관리 (`GA_MEASUREMENT_ID`), 하드코딩 금지 |
| gtag 유틸 | `pageview`, `event` 함수 분리 (재사용 가능한 단일 모듈) |
| SPA 페이지뷰 | 라우트 변경 감지 컴포넌트로 `page_view` 수동 전송 |
| 타입 선언 | `window.gtag` TypeScript 타입 파일 (`gtag.d.ts`) |
| 개발/프로덕션 분리 | 개발 환경에서는 콘솔 로그만, 프로덕션에서만 실제 전송 |

### 1.2 CSP (Content Security Policy) 허용

GA 사용 시 반드시 CSP에 추가해야 할 도메인:

```
script-src: https://www.googletagmanager.com
connect-src: https://www.google-analytics.com
             https://www.googletagmanager.com
             https://analytics.google.com
img-src:     https://www.googletagmanager.com
```

### 1.3 GCP API 활성화 (고급)

내부 대시보드나 자동 보고서를 만들 때 필요:

| API | 용도 |
|-----|------|
| `analyticsdata.googleapis.com` | GA4 Data API (데이터 조회) |
| `analyticsadmin.googleapis.com` | GA Admin API (속성 관리) |
| `searchconsole.googleapis.com` | Search Console 연동 |

---

## 2. 이벤트 설계 원칙

### 2.1 네이밍 컨벤션

```
{동사}_{대상}        # 기본 형태
{기능}_{동사}_{대상}  # 기능별 네임스페이스

예시:
login, sign_up, logout                    # 인증
view_item, add_to_cart, purchase          # 전자상거래 (GA4 표준)
click_banner, filter_change, search       # 사용자 행동
share_link_copy, share_kakao             # 공유
consult_submit, consult_start_click      # 기능별 네임스페이스
```

### 2.2 GA4 표준 이벤트 vs 커스텀 이벤트

**GA4 표준 이벤트를 최대한 활용** (보고서 자동 매핑):

| 카테고리 | 표준 이벤트 | 트리거 시점 |
|----------|------------|-------------|
| 인증 | `login`, `sign_up` | 로그인/가입 성공 |
| 전자상거래 | `view_item`, `add_to_cart`, `begin_checkout`, `purchase` | 구매 퍼널 단계별 |
| 콘텐츠 | `view_item_list`, `select_item` | 목록 조회, 아이템 클릭 |
| 검색 | `search` | 검색어 입력 |
| 공유 | `share` | 콘텐츠 공유 |

**커스텀 이벤트는 표준으로 커버 불가한 비즈니스 로직에만 사용**

### 2.3 이벤트 파라미터 설계

```typescript
// 모든 이벤트에 공통으로 포함할 파라미터
{
  // GA4가 자동 수집하는 것: page_location, page_title, session_id 등
  // 수동 추가 권장:
  is_logged_in: boolean,   // 로그인 여부 → 전환율 분기 분석
  source: string,          // 진입 경로 (어디서 트리거됐는지)
}

// 전자상거래 이벤트 필수 파라미터
{
  currency: 'KRW',         // 통화 코드 필수
  value: number,           // 금액 필수
  items: [{                // items 배열 필수
    item_id: string,
    item_name: string,
    item_category: string,
    price: number,
    quantity: number,
  }],
}
```

---

## 3. 페이지 타이틀 전략

### 3.1 SPA 페이지 타이틀 설정

SPA에서는 GA4가 자동으로 `document.title`을 읽으므로, 라우트별로 명확한 타이틀 설정 필수:

```typescript
// 라우트 → 타이틀 매핑
const PAGE_TITLES: Record<string, string> = {
  '/': '홈 | 브랜드명',
  '/login': '로그인 | 브랜드명',
  '/product/:id': '상품 상세 | 브랜드명',
  '/checkout': '결제 | 브랜드명',
  '/result': '결과 | 브랜드명',
};
```

### 3.2 이중 page_view 패턴 (고급)

동적 콘텐츠 상세 페이지에서 2개의 page_view를 전송하면 퍼널 + 개별 성과를 동시 분석:

| 시점 | 타이틀 | 용도 |
|------|--------|------|
| 페이지 진입 즉시 | `상품 상세 \| 브랜드` | 전체 퍼널 전환율 |
| 콘텐츠 로드 후 | `[유료] 상품명 \| 브랜드` | 개별 콘텐츠 성과 |

**GA에서 확인**:
- "상품 상세" → 전체 상세 페이지 조회 합산
- "[유료] 상품명" → 개별 상품 조회수

### 3.3 접두사 규칙

유료/무료, 카테고리 구분을 위해 타이틀에 접두사 활용:
- `[유료]`, `[무료]` → GA에서 필터링 용이
- 카테고리별 구분 필요 시 추가 접두사

---

## 4. 전자상거래 퍼널

### 4.1 표준 구매 퍼널

```
세션 시작 → 상품 보기 → 장바구니 추가 → 결제 시작 → 구매 완료
(자동)     (view_item)  (add_to_cart)  (begin_checkout)  (purchase)
```

GA4 > 판매 촉진 > 구매 여정에서 자동 시각화

### 4.2 0원 결제 제외 정책

무료 전환(쿠폰 100% 할인, 무료 체험 등)은 구매 이벤트에서 **반드시 제외**:

```typescript
// 제외 대상: add_to_cart, begin_checkout, purchase
if (finalPrice <= 0) {
  console.log('Purchase tracking skipped (0원 결제)');
  return;
}
```

**이유**:
1. 실제 매출만 정확히 추적
2. 유료 전환율 왜곡 방지
3. 마케팅 ROI 정확도 보장

### 4.3 purchase 이벤트 상세

```typescript
// 필수 파라미터
{
  transaction_id: string,    // 주문 고유 ID (중복 방지)
  value: number,             // 실제 결제 금액 (쿠폰 적용 후)
  currency: 'KRW',
  items: [{ item_id, item_name, price, quantity }],
}

// 권장 커스텀 파라미터
{
  payment_method: string,    // 결제 수단
  coupon_used: boolean,      // 쿠폰 사용 여부
  coupon_type: string,       // 쿠폰 종류
  coupon_amount: number,     // 할인 금액
  original_price: number,    // 정가 (할인 전)
}
```

---

## 5. 마케팅 퍼널 이벤트 설계

### 5.1 범용 마케팅 퍼널

비즈니스별로 커스텀 퍼널을 설계할 때의 템플릿:

```
인지 → 관심 → 가입 → 활성화 → 전환 → 리텐션 → 추천
```

| 단계 | 이벤트 예시 | 파라미터 |
|------|------------|----------|
| 인지 | `page_view` (랜딩) | 유입 경로 |
| 관심 | `content_click`, `search` | content_id |
| 가입 | `sign_up`, `welcome_coupon_issued` | method, coupon_amount |
| 활성화 | `feature_used`, `form_submit` | feature_name |
| 전환 | `purchase`, `subscription_start` | value, plan |
| 리텐션 | `return_visit`, `feature_reused` | days_since_last |
| 추천 | `share_link_copy`, `share_kakao`, `referral_sent` | channel |

### 5.2 로그인 전환 퍼널

비회원 → 회원 전환 추적:

```
login_click → login/sign_up → welcome_coupon_issued → first_purchase
```

- `login_click`에 `source` 파라미터로 어디서 로그인 유도가 발생했는지 추적
- 비회원 제한 기능 사용 시 로그인 유도 → 해당 source별 전환율 비교

### 5.3 기능별 퍼널 패턴

각 핵심 기능마다 진입→사용→전환 퍼널 설계:

```
{기능}_page_view → {기능}_action → {기능}_complete → {기능}_conversion
```

예시 (상담 기능):
```
consult_entry_click → consult_type_select → consult_submit → consult_recommendation_click
```

파라미터로 분기:
- `consult_type`: 유형별 전환율 비교
- `is_logged_in`: 로그인 여부별 완료율
- `source`: 진입 경로별 효과

---

## 6. 이벤트 카테고리별 설계 템플릿

### 6.1 인증

| 이벤트 | 파라미터 | 트리거 |
|--------|---------|--------|
| `login` | `method` (kakao/google/email) | 로그인 성공 |
| `sign_up` | `method` | 회원가입 성공 |
| `logout` | - | 로그아웃 클릭 |
| `login_click` | `source` (어디서 유도) | 로그인 버튼 클릭 |

### 6.2 콘텐츠 소비

| 이벤트 | 파라미터 | 트리거 |
|--------|---------|--------|
| `view_item_list` | `item_list_name`, `items[]` | 목록 페이지 진입 |
| `select_item` | `item_id`, `item_name` | 카드/리스트 아이템 클릭 |
| `view_item` | `item_id`, `item_name`, `price` | 상세 페이지 진입 |
| `load_more` | `page_number` | 더보기/무한스크롤 |
| `filter_change` | `filter_type`, `filter_value` | 필터 변경 |
| `search` | `search_term` | 검색 실행 |

### 6.3 전자상거래

| 이벤트 | 파라미터 | 트리거 | 0원 제외 |
|--------|---------|--------|---------|
| `add_to_cart` | `currency`, `value`, `items[]` | 결제 페이지 진입 | O |
| `begin_checkout` | `currency`, `value`, `items[]` | 구매 버튼 클릭 | O |
| `add_payment_info` | `payment_type` | 결제수단 선택 | - |
| `purchase` | `transaction_id`, `value`, `items[]` | 결제 완료 | O |

### 6.4 공유

| 이벤트 | 파라미터 | 트리거 |
|--------|---------|--------|
| `share_modal_open` | `content_id`, `is_logged_in` | 공유 UI 열림 |
| `share_link_copy` | `content_id` | 링크 복사 |
| `share_{channel}` | `content_id` | 채널별 공유 (kakao, twitter 등) |

### 6.5 AI/챗봇 기능

| 이벤트 | 파라미터 | 트리거 |
|--------|---------|--------|
| `chat_message_send` | `mode`, `is_logged_in` | 메시지 전송 |
| `chat_mode_change` | `mode` | 모드 변경 |
| `chat_reference` | `article_id` | 참조 콘텐츠 핀 |

### 6.6 설정/기타

| 이벤트 | 파라미터 | 트리거 |
|--------|---------|--------|
| `language_change` | `language` | 언어 변경 |
| `theme_change` | `theme` | 테마 변경 |
| `notification_toggle` | `enabled` | 알림 설정 변경 |

---

## 7. 중복 방지 & 데이터 품질

### 7.1 page_view 중복 방지

```typescript
// 결과 페이지 등 재방문 가능한 페이지
const viewedKey = `viewed_${pageType}_${id}`;
const alreadyViewed = localStorage.getItem(viewedKey);

if (!alreadyViewed) {
  trackPageView({ page_title: title });
  localStorage.setItem(viewedKey, 'true');
}
```

### 7.2 이벤트 중복 방지

- 페이지 리렌더링 시 `useEffect` deps 관리로 중복 전송 방지
- `useRef` 플래그로 한 세션 내 1회만 전송
- `transaction_id`로 purchase 중복 자동 제거 (GA4 내장)

### 7.3 Safari ITP 대응

- 쿠키 만료: 2년 설정 (ITP 7일 제한 회피)
- `SameSite=Lax` 설정
- 서버사이드 GA (Measurement Protocol) 고려 — 클라이언트 차단 우회

---

## 8. 사용자 식별

### 8.1 user_id 설정

```typescript
// 로그인 시 user_id 설정 → 교차 기기 추적
gtag('set', { user_id: userId });

// 로그아웃 시 해제
gtag('set', { user_id: null });
```

### 8.2 커스텀 사용자 속성

비즈니스에 따라 사용자 속성 추가:
```typescript
gtag('set', 'user_properties', {
  account_type: 'premium',     // 계정 유형
  signup_date: '2026-01-15',   // 가입일
  preferred_language: 'ko',    // 선호 언어
});
```

---

## 9. GA4 보고서 활용

### 9.1 핵심 보고서 매핑

| GA4 보고서 | 활용할 이벤트 | 인사이트 |
|-----------|-------------|---------|
| 판매 촉진 > 개요 | `purchase` | 총수익, 구매자 수, 상품별 매출 |
| 판매 촉진 > 구매 여정 | 전자상거래 4종 | 단계별 이탈률 |
| 참여도 > 페이지 및 화면 | `page_view` | 페이지별 조회수, 체류 시간 |
| 참여도 > 이벤트 | 모든 이벤트 | 이벤트별 발생 횟수 |
| 사용자 속성 | user_properties | 세그먼트별 행동 차이 |

### 9.2 커스텀 퍼널 (탐색)

GA4 > 탐색 > 퍼널 탐색에서 비즈니스별 퍼널 구성:

1. **가입 퍼널**: `page_view(랜딩)` → `login_click` → `sign_up`
2. **구매 퍼널**: `view_item` → `add_to_cart` → `begin_checkout` → `purchase`
3. **기능 활성화 퍼널**: `feature_view` → `feature_action` → `feature_complete`

### 9.3 주의사항

- **데이터 지연**: 표준 보고서 24~48시간, 실시간은 즉시
- **이벤트 파라미터 제한**: 이벤트당 최대 25개 파라미터
- **커스텀 디멘션 제한**: 이벤트 스코프 50개, 사용자 스코프 25개
- **데이터 보존**: 기본 2개월 → 14개월로 변경 권장 (관리 > 데이터 설정)

---

## 10. 디버깅

### 10.1 개발 환경

```typescript
// 개발 환경에서 콘솔 로그 출력
if (isDev) {
  console.log(`📊 Event: ${eventName}`, params);
  return; // 실제 전송 안 함
}
window.gtag('event', eventName, params);
```

### 10.2 디버깅 도구

| 도구 | 용도 |
|------|------|
| GA4 DebugView | 실시간 이벤트 상세 확인 (Chrome GA Debugger 확장 필요) |
| GA4 실시간 | 프로덕션 이벤트 실시간 모니터링 |
| Chrome DevTools Network | `collect?` 필터로 GA 요청 확인 |
| Tag Assistant | GTM 사용 시 태그 발동 확인 |

### 10.3 흔한 문제

| 증상 | 원인 | 해결 |
|------|------|------|
| 이벤트 안 찍힘 | CSP 차단 | `connect-src`에 GA 도메인 추가 |
| 매출 0원 | `currency` 누락 | `currency: 'KRW'` 추가 |
| 구매 여정 비어있음 | `items[]` 누락 | 전자상거래 이벤트에 items 배열 필수 |
| 페이지 타이틀 동일 | SPA 타이틀 미설정 | 라우트별 `document.title` 설정 |
| 전환율 비정상 | 0원 결제 포함 | 0원 결제 제외 로직 추가 |
| 중복 이벤트 | 리렌더링 | useRef/localStorage 가드 |

---

## 11. 구현 체크리스트

### 초기 설정
- [ ] GA4 속성 생성 + 측정 ID 환경변수 등록
- [ ] gtag 유틸 모듈 생성 (`pageview`, `event` 함수)
- [ ] SPA 라우트 변경 감지 → page_view 전송 컴포넌트
- [ ] CSP에 GA 도메인 허용
- [ ] 개발 환경 콘솔 로그 분기
- [ ] `window.gtag` TypeScript 타입 선언
- [ ] 데이터 보존 기간 14개월로 변경

### 이벤트 구현
- [ ] 인증: `login`, `sign_up`, `logout`
- [ ] 전자상거래 퍼널: `view_item` → `add_to_cart` → `begin_checkout` → `purchase`
- [ ] 0원 결제 제외 로직
- [ ] 페이지 타이틀 라우트별 설정
- [ ] 핵심 기능별 커스텀 퍼널 이벤트
- [ ] 공유 이벤트
- [ ] user_id 설정 (로그인/로그아웃)

### 검증
- [ ] DebugView에서 모든 이벤트 정상 수신 확인
- [ ] 구매 여정 퍼널 시각화 확인
- [ ] 0원 결제 제외 동작 확인
- [ ] 중복 이벤트 없는지 확인
- [ ] Search Console 연동

---

## 12. 핵심 원칙 요약

1. **GA4 표준 이벤트 우선** — 보고서 자동 매핑, 커스텀은 표준으로 불가할 때만
2. **0원 결제 제외** — 전자상거래 이벤트에서 무료 전환 반드시 제외
3. **items 배열 필수** — 전자상거래 이벤트에 items 없으면 구매 여정 작동 안 함
4. **currency 필수** — 금액 이벤트에 통화 코드 없으면 매출 0원
5. **페이지별 고유 타이틀** — SPA도 라우트별 document.title 필수
6. **중복 방지** — localStorage/useRef로 재방문 시 중복 이벤트 차단
7. **개발/프로덕션 분리** — 개발 데이터가 프로덕션 보고서 오염 방지
8. **퍼널은 비즈니스 단위로** — 기능별 진입→사용→전환 퍼널 개별 설계
9. **source 파라미터** — 모든 전환 이벤트에 진입 경로 추적
10. **is_logged_in 파라미터** — 로그인/비로그인 전환율 분기 분석

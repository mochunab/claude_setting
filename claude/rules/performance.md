# 성능 규칙 (모든 코딩 작업에 자동 적용)

## 미들웨어
- `middleware.ts`에서 네트워크 호출 금지 (`auth.getUser()`, `fetch()` 등)
- 보안 헤더는 `next.config.mjs headers()`에서 처리

## 서버 컴포넌트
- 순차 await 체인 → `Promise.all` 병렬화
- 자주 접근하는 페이지는 인메모리 캐시 (`getCache/setCache`) 적용
- 캐시 TTL은 데이터 갱신 주기의 30~60%

## 캐시 무효화
- 데이터 변경 API에서 관련 캐시 반드시 무효화 (`invalidateCache`)
- 캐시 추가 시 무효화 누락은 stale 데이터 직결

## 클라이언트
- 탭/필터 전환이 있는 컴포넌트 → `useRef` 캐시로 즉시 표시
- SSR initialData → `useState` 초기값으로 활용
- 스켈레톤(`loading.tsx`)과 텍스트 로딩 중복 금지

## API 라우트
- `Cache-Control: no-store` 하드코딩 금지 — `next.config.mjs`에서 통합 관리
- `staleTimes.dynamic: 0` 금지 (최소 30 이상)

## 네트워크 안정성
- 외부 API/DB 호출에 fetchWithRetry 적용 (3회, Exponential Backoff, 5xx만 재시도)
- 타임아웃 필수 설정 — 무한 대기 방지

## 에러 복원력
- ErrorBoundary로 앱 전체 감싸기 — 에러 시 빈 화면 대신 복구 UI 표시
- 에러 타입(network/500/404) 자동 분류 → 맞춤 메시지

## HTTP 캐시 세분화
- 정적 리소스(빌드 해시) → `immutable`
- 이미지 → `max-age + stale-while-revalidate`
- HTML/API → 용도에 맞는 s-maxage
- 모든 리소스 동일 캐시 정책 금지

## 이미지
- 뷰포트 밖 이미지 → lazy loading
- 반복 사용 이미지 → 프리로드 (priority 기반: high=동시, low=분산)

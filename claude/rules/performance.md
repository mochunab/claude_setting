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

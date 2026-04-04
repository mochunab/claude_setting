# 범용 웹 성능 최적화 전략서

> 어떤 웹 프로젝트에든 적용 가능한 성능 최적화 원칙, 캐시 전략, 체크리스트
> 대상 스택: React/Next.js + BaaS(Supabase 등) + Serverless (범용 적용 가능)
> 최종 업데이트: 2026-04-03

---

## 문제 진단 순서

페이지가 느릴 때 아래 순서로 확인:

1. **미들웨어/가드** — 매 요청마다 네트워크 호출하는 코드가 있는가?
2. **서버 컴포넌트/API** — 순차 await 체인인가, 캐시 없이 매번 DB 쿼리하는가?
3. **클라이언트** — auth/API 완료까지 빈 화면인가, 캐시 데이터 활용하는가?
4. **프레임워크 설정** — 라우터 캐시가 비활성화(0)인가?

---

## 1. 미들웨어 경량화

### 원칙
미들웨어는 **모든 페이지 네비게이션에 실행**된다. 네트워크 호출이 있으면 모든 페이지가 느려진다.

### 금지
```typescript
// middleware.ts — 절대 하지 말 것
await auth.getUser();      // 인증 서비스 네트워크 호출 (200-500ms)
await fetch('...');         // 외부 API 호출
```

### 권장
```typescript
// middleware.ts — 순수 로직만
export function middleware(request: NextRequest) {
  // i18n 라우팅, CORS, rate limit 등 순수 로직만
  // 보안 헤더는 next.config.mjs headers()에서 처리
  const response = NextResponse.next();
  return response;
}
```

### 핵심
- 인증 체크는 클라이언트 AuthProvider 또는 서버 컴포넌트에서 처리
- 보안 헤더는 `next.config.mjs headers()`에서 통합 관리
- 미들웨어에서 import하는 라이브러리도 번들 크기에 영향 — 불필요한 import 제거

---

## 2. 비동기 작업 병렬화

### 원칙
독립적인 비동기 작업은 반드시 `Promise.all`로 병렬 실행.

### Before (느림)
```typescript
const user = await getUser();         // 200ms
const settings = await getSettings(); // 100ms
const data = await fetchData();       // 300ms
// 총: 600ms (순차)
```

### After (빠름)
```typescript
const [user, settings, data] = await Promise.all([
  getUser(),
  getSettings(),
  fetchData(),
]);
// 총: ~300ms (병렬, 가장 느린 것 기준)
```

### 적용 기준
- 서로 의존하지 않는 DB 쿼리, API 호출, 인증 체크
- 의존 관계가 있으면 의존부만 순차, 나머지는 병렬

---

## 3. 캐시 전략 (4단계 레이어)

### 3.1 서버 인메모리 캐시

서버 컴포넌트/API 라우트에서 DB 결과를 메모리에 캐시:

```typescript
import { getCache, setCache } from '@/lib/cache';

const CACHE_KEY = 'ssr:home';
const CACHE_TTL = 30_000; // 30초

export default async function Page() {
  const cached = getCache<PageData>(CACHE_KEY);
  if (cached) return <Component initialData={cached} />;

  const data = await fetchFromDB();
  setCache(CACHE_KEY, data, CACHE_TTL);
  return <Component initialData={data} />;
}
```

**TTL 기준**: 데이터 갱신 주기의 30~60%
- 거의 안 바뀌는 데이터 (설정, 카테고리) → 5분
- 주기적 갱신 데이터 (크롤링, 배치) → 30초~1분
- 실시간성 필요 (채팅, 알림) → 캐시 안 함

### 3.2 클라이언트 캐시 레이어 (우선순위순)

```
1. useState 초기값 (in-memory, 같은 세션 내 즉시)
2. useRef Map (탭/필터별 캐시, 전환 즉시)
3. sessionStorage (탭 내 네비게이션 간 유지, 5분 TTL)
4. localStorage (영구 저장, 사용자 설정)
5. Cache API (이미지, 정적 리소스)
6. API 호출 (stale-while-revalidate)
```

### 3.3 SSR initialData 패턴

```typescript
// 서버 컴포넌트에서 데이터 fetch → 클라이언트 props로 전달
export default async function Page() {
  const data = await fetchData();
  return <ClientComponent initialData={data} />;
}

// 클라이언트 컴포넌트에서 초기값으로 활용
function ClientComponent({ initialData }) {
  const [items, setItems] = useState(initialData);
  // 첫 렌더부터 데이터 표시, 이후 클라이언트에서 갱신
}
```

### 3.4 sessionStorage 캐시 우선 렌더

```typescript
function loadCachedState() {
  try {
    const cached = sessionStorage.getItem('app:data');
    if (cached) {
      const { data, timestamp } = JSON.parse(cached);
      if (Date.now() - timestamp < 5 * 60 * 1000) { // 5분 TTL
        return { items: data, hasCachedData: true };
      }
    }
  } catch { /* ignore */ }
  return { items: [], hasCachedData: false };
}

export default function MyPage() {
  const [cached] = useState(loadCachedState);
  const [items, setItems] = useState(cached.items);
  const [isLoading, setIsLoading] = useState(!cached.hasCachedData);
}
```

---

## 4. 캐시 무효화

### 원칙
**캐시 추가 시 무효화 누락 = stale 데이터 직결.** 캐시를 추가할 때 반드시 무효화 지점도 함께 구현한다.

### 패턴
```typescript
// 데이터 변경 API에서 관련 캐시 무효화
export async function POST(request: Request) {
  await insertData(newData);

  // 관련 캐시 무효화
  invalidateCache('ssr:home');
  invalidateCacheByPrefix('api:articles');

  return Response.json({ success: true });
}
```

### 무효화 전략

| 전략 | 설명 | 적합한 경우 |
|------|------|-------------|
| TTL 만료 | 시간 기반 자동 만료 | 갱신 주기가 예측 가능할 때 |
| 명시적 무효화 | CRUD 시 직접 삭제 | 데이터 정합성이 중요할 때 |
| 프리픽스 무효화 | 같은 접두사 캐시 일괄 삭제 | 관련 캐시가 여러 개일 때 |
| 버전 키 | 캐시 키에 버전 포함 | 스키마 변경 시 전체 갱신 |

---

## 5. 클라이언트 렌더링 최적화

### 5.1 캐시 바이패스 (auth 블로킹 해소)

```typescript
// Before (느림) — auth 완료까지 무조건 스켈레톤
if (!authChecked) return <Skeleton />;

// After (빠름) — 캐시 있으면 즉시 렌더
if (!authChecked && !hasCachedData) return <Skeleton />;
```

### 5.2 탭/필터 전환 캐시

```typescript
// useRef Map으로 탭별 데이터 캐시 → 전환 시 즉시 표시
const tabCache = useRef<Map<string, Item[]>>(new Map());

function onTabChange(tab: string) {
  const cached = tabCache.current.get(tab);
  if (cached) {
    setItems(cached); // 즉시 표시
    return;
  }
  fetchItems(tab).then(data => {
    tabCache.current.set(tab, data);
    setItems(data);
  });
}
```

### 5.3 로딩 상태 규칙

- 스켈레톤(`loading.tsx`)과 텍스트 로딩("로딩 중...") **중복 금지**
- 캐시 데이터가 있으면 스켈레톤 대신 캐시 데이터 즉시 표시
- 백그라운드 갱신 중엔 subtle indicator (스피너, 프로그레스 바)만

---

## 6. Provider/Context 값 재활용

### 원칙
전역 Provider에서 이미 제공하는 값을 컴포넌트에서 별도 DB 쿼리하지 않는다.

### Before (중복 쿼리)
```typescript
const { user } = useAuth();
useEffect(() => {
  db.from('users').select('role').eq('id', user.id).single()
    .then(({ data }) => setRole(data.role));
}, [user]);
```

### After (Provider 재활용)
```typescript
const { user, role } = useAuth(); // Provider에서 이미 제공
```

### 체크
- AuthProvider의 `user`, `role`, `isAdmin` 등 이미 제공하는 값 확인
- 테마, 언어, 설정 등 Context에서 이미 관리하는 값 중복 fetch 금지

---

## 7. HTTP 캐시 전략

### 리소스별 캐시 정책

| 리소스 유형 | Cache-Control | 이유 |
|-------------|---------------|------|
| 정적 리소스 (빌드 해시) | `public, max-age=31536000, immutable` | 파일명에 해시 포함, 변경 시 새 URL |
| 이미지 | `public, max-age=86400, stale-while-revalidate=604800` | 1일 캐시 + 7일 SWR |
| HTML | `public, s-maxage=60, stale-while-revalidate=300` | CDN 1분 + 5분 SWR |
| API (동적) | `public, s-maxage=30, stale-while-revalidate=60` | 용도에 맞게 조정 |
| API (실시간) | `no-cache` 또는 `s-maxage=0` | 항상 최신 |

### 금지
- `Cache-Control: no-store` 하드코딩 금지 — 프레임워크 설정에서 통합 관리
- 모든 리소스에 동일 캐시 정책 적용 금지

### Next.js 라우터 캐시
```javascript
// next.config.mjs
experimental: {
  staleTimes: {
    dynamic: 30,   // 동적 페이지 30초 캐시 (0 금지)
    static: 180,   // 정적 페이지 3분 캐시
  },
},
```

---

## 8. 네트워크 안정성

### 재시도 패턴

```typescript
async function fetchWithRetry(
  url: string,
  options?: RequestInit,
  { retries = 3, baseDelay = 1000, timeout = 10000 } = {}
) {
  for (let i = 0; i <= retries; i++) {
    try {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), timeout);

      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
      });
      clearTimeout(timer);

      if (response.ok) return response;
      if (response.status < 500) throw new Error(`${response.status}`);
      // 5xx만 재시도
    } catch (error) {
      if (i === retries) throw error;
      await new Promise(r => setTimeout(r, baseDelay * 2 ** i));
    }
  }
}
```

### 핵심 규칙
- 외부 API/DB 호출에 **타임아웃 필수** — 무한 대기 방지
- **Exponential Backoff** — 1초, 2초, 4초
- **5xx만 재시도** — 4xx는 재시도해도 같은 결과
- 재시도 횟수: 3회 (초과 시 에러 전파)

---

## 9. 에러 복원력

### ErrorBoundary
```typescript
// 앱 전체를 감싸서 에러 시 빈 화면 대신 복구 UI 표시
<ErrorBoundary fallback={<ErrorFallback />}>
  <App />
</ErrorBoundary>
```

### 에러 분류
```typescript
function classifyError(error: unknown): 'network' | 'server' | 'notFound' | 'unknown' {
  if (error instanceof TypeError) return 'network';
  if (error instanceof Response) {
    if (error.status === 404) return 'notFound';
    if (error.status >= 500) return 'server';
  }
  return 'unknown';
}
```

### 사용자 메시지 원칙
- `error.message` 직접 노출 금지 — 내부 정보 유출 위험
- 에러 타입별 맞춤 메시지 표시
- 상세 에러는 `console.error`로만

---

## 10. 이미지 최적화

### 로딩 전략
| 위치 | 전략 | 구현 |
|------|------|------|
| Hero / 첫 화면 | 즉시 로드 | `loading="eager"` 또는 `fetchpriority="high"` |
| 뷰포트 밖 | 지연 로드 | `loading="lazy"` |
| 반복 사용 이미지 | 프리로드 | `<link rel="preload">` 또는 Cache API |

### 최적화 체크리스트
- WebP/AVIF 포맷 변환 (Next.js `<Image>` 자동 처리)
- 적절한 `sizes` 속성으로 불필요한 대용량 이미지 방지
- CDN + HTTP 캐시 (`max-age` + `stale-while-revalidate`)
- 배치 프리페칭: 현재 보이는 이미지 + 다음 N개까지만

---

## 11. 폰트 최적화

| 방법 | 효과 |
|------|------|
| CDN `<link>` → self-hosting (`next/font`) | 렌더 블로킹 제거 |
| `font-display: swap` | FOIT(안 보이는 텍스트) 방지 |
| 가변 폰트(Variable Font) | 단일 파일로 모든 weight |
| 사용 weight만 subset | 파일 크기 절감 |

---

## 새 페이지 개발 시 체크리스트

### 서버
- [ ] 순차 await 체인 → `Promise.all` 병렬화 가능한가?
- [ ] 자주 접근하는 페이지에 인메모리 캐시 필요한가?
- [ ] 캐시 추가 시 무효화 지점도 함께 구현했나?
- [ ] TTL은 데이터 갱신 주기의 30~60%인가?

### 클라이언트
- [ ] SSR initialData → `useState` 초기값으로 활용했나?
- [ ] sessionStorage 캐시 → state 초기값 패턴 적용했나?
- [ ] 탭/필터 전환에 `useRef` 캐시 적용했나?
- [ ] auth/API 블로킹 가드에 캐시 바이패스 조건 추가했나?
- [ ] 스켈레톤과 텍스트 로딩이 중복되지 않는가?

### 데이터
- [ ] Provider에서 이미 제공하는 값을 중복 쿼리하지 않는가?
- [ ] 데이터 변경 시 관련 캐시 무효화 연동했나?
- [ ] 외부 API 호출에 타임아웃 + 재시도 적용했나?

### HTTP
- [ ] 리소스 유형별 적절한 Cache-Control 설정했나?
- [ ] `Cache-Control: no-store` 하드코딩하지 않았나?
- [ ] `staleTimes.dynamic`이 최소 30 이상인가?

### 이미지/폰트
- [ ] Hero 이미지 eager, 나머지 lazy 적용했나?
- [ ] 폰트 self-hosting + `font-display: swap` 적용했나?

### 에러
- [ ] ErrorBoundary로 에러 시 빈 화면 방지했나?
- [ ] 에러 타입별 맞춤 메시지 표시하는가?

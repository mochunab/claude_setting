# 범용 웹 보안 전략서

> 어떤 웹 프로젝트에든 적용 가능한 보안 체크리스트, 정책 설계, 인시던트 대응 가이드
> 대상 스택: React/Next.js + BaaS(Supabase 등) + Serverless + CDN (범용 적용 가능)
> 최종 업데이트: 2026-04-03

---

## 1. 보안 아키텍처 레이어

```
┌─────────────────────────────────────────────────┐
│  클라이언트 (React/Next.js)                       │
│  - CSP 적용 (XSS 방지)                           │
│  - 민감 정보 마스킹 (로그에서)                     │
│  - 에러 메시지 일반화                              │
└────────────────────┬────────────────────────────┘
                     ▼
┌─────────────────────────────────────────────────┐
│  호스팅/CDN (Vercel, Cloudflare 등)               │
│  - HTTPS 강제                                     │
│  - 보안 헤더 (X-Frame-Options 등)                 │
│  - CSP 헤더 전송                                  │
└────────────────────┬────────────────────────────┘
                     ▼
┌─────────────────────────────────────────────────┐
│  API / Edge Functions                             │
│  - CORS 화이트리스트                               │
│  - JWT/세션 인증 검증                              │
│  - Rate Limiting                                  │
└────────────────────┬────────────────────────────┘
                     ▼
┌─────────────────────────────────────────────────┐
│  데이터베이스                                      │
│  - RLS (Row Level Security)                       │
│  - 암호화된 연결 (SSL)                             │
│  - Service Role Key 분리                           │
└─────────────────────────────────────────────────┘
```

---

## 2. 절대 금지 (모든 프로젝트 공통)

| 금지 사항 | 해야 할 것 |
|----------|-----------|
| API 키, 시크릿 하드코딩 | 환경변수 필수 (`VITE_*`, `NEXT_PUBLIC_*`, `Deno.env.get()`) |
| `error.message` 사용자 직접 노출 | 일반 메시지만 표시, 상세는 `console.error` |
| `.env` 파일 git 커밋 | `.gitignore`에 `.env*` 포괄 패턴 |
| 외부 이미지/스크립트 URL 무분별 추가 | CSP 허용 목록에 있는 도메인만 |
| CORS `*` (전체 허용) | Origin 화이트리스트 방식 |
| SQL 문자열 연결 | 파라미터 바인딩 필수 |

---

## 3. 보안 헤더

### 필수 헤더 5종

| 헤더 | 값 | 방어 대상 |
|------|-----|----------|
| **X-Frame-Options** | `DENY` | 클릭재킹 (iframe 삽입 차단) |
| **X-Content-Type-Options** | `nosniff` | MIME 타입 스니핑 |
| **X-XSS-Protection** | `1; mode=block` | 반사형 XSS (레거시 브라우저) |
| **Referrer-Policy** | `strict-origin-when-cross-origin` | 리퍼러 정보 유출 |
| **Permissions-Policy** | `camera=(), microphone=(), geolocation=()` | 불필요한 브라우저 권한 차단 |

### 설정 위치

- **Next.js**: `next.config.mjs` `headers()` 또는 `middleware.ts`
- **Vite/SPA**: `vercel.json` headers 또는 호스팅 플랫폼 설정
- **미들웨어에서 보안 헤더 설정 금지** — 프레임워크 설정에서 통합 관리

---

## 4. Content Security Policy (CSP)

### 지시문별 설계 원칙

| 지시문 | 원칙 | 주의사항 |
|--------|------|---------|
| **default-src** | `'self'` | 기본 차단, 필요한 것만 허용 |
| **script-src** | `'self'` + 필요한 외부 스크립트만 | 결제 SDK, 인증 SDK, 애널리틱스 |
| **connect-src** | `'self'` + API/DB/모니터링 도메인 | Supabase, Sentry, GA 등 |
| **img-src** | `'self' data: blob:` + 이미지 CDN | 스토리지, 프로필 이미지 |
| **frame-src** | 결제/인증 iframe 도메인만 | PG사 서브도메인 누락 주의 |
| **form-action** | `'self'` + 결제/인증 redirect 도메인 | 모바일 redirect 경로 포함 |
| **object-src** | `'none'` | Flash/Plugin 완전 차단 |

### CSP 변경 시 필수 테스트

> **실제 사례**: CSP 도입 시 결제 도메인 2개 누락으로 **3주간 결제 장애** 발생.
> PG사는 공식 문서에 없는 서브도메인/파트너 도메인을 사용할 수 있음.

CSP 변경 후 반드시:
- [ ] **모든 결제 수단** (카드/간편결제/계좌이체) 테스트
- [ ] **PC + 모바일** 양쪽 테스트
- [ ] **OAuth 로그인** (카카오/구글/애플) 테스트
- [ ] **외부 공유** (카카오톡/트위터 등) 테스트

### `unsafe-inline` / `unsafe-eval`

- React/Vite/Next.js 빌드 호환성을 위해 현실적으로 필요한 경우가 많음
- 장기적으로 nonce 기반 CSP로 강화 권장
- SRI(Subresource Integrity)로 CDN 스크립트 변조 감지 추가 가능

---

## 5. CORS 정책

### 설계 원칙

```typescript
// 화이트리스트 방식 — * 절대 금지
const ALLOWED_ORIGINS = [
  'https://example.com',
  'https://www.example.com',
  'https://staging.example.com',
];

// localhost는 개발 환경에서만 허용
if (isDev) {
  // http://localhost:* 허용
}
```

### 검증 방법

```bash
# 허용된 Origin 테스트
curl -I -X OPTIONS "https://api.example.com/endpoint" \
  -H "Origin: https://example.com" \
  -H "Access-Control-Request-Method: POST"
# → Access-Control-Allow-Origin: https://example.com

# 차단된 Origin 테스트
curl -I -X OPTIONS "https://api.example.com/endpoint" \
  -H "Origin: https://evil-site.com"
# → Access-Control-Allow-Origin 헤더 없음
```

---

## 6. 인증 및 권한

### 인증 설계 원칙

| 원칙 | 설명 |
|------|------|
| OAuth 우선 | 자체 비밀번호 관리보다 OAuth(카카오/구글) 위임 |
| JWT 토큰 분리 | Access Token(단기) + Refresh Token(장기) |
| RLS 필수 | DB 레벨에서 사용자별 데이터 접근 제어 |
| Service Role 분리 | 클라이언트용 anon key ≠ 서버용 service role key |

### RLS (Row Level Security) 패턴

```sql
-- 기본: 사용자는 자신의 데이터만 접근
CREATE POLICY "Users can view own data"
ON table_name FOR SELECT
USING (auth.uid() = user_id);

-- 공개 데이터: 모든 사용자 읽기 허용
CREATE POLICY "Public read access"
ON public_content FOR SELECT
USING (published = true);
```

### API 엔드포인트 보안

| 엔드포인트 유형 | 인증 방식 |
|---------------|----------|
| 공개 API (읽기) | 인증 불필요, Rate Limit만 |
| 사용자 API (CRUD) | JWT/세션 검증 필수 |
| 내부 API (서버→서버) | Bearer Token 또는 Service Role |
| Webhook | 서명 검증 (HMAC) |

---

## 7. Rate Limiting

### 적용 우선순위

| 엔드포인트 유형 | 위험도 | 권장 제한 |
|---------------|--------|----------|
| AI/LLM 호출 (비용 발생) | 높음 | 10회/분/사용자 |
| 외부 API 과금 (알림톡 등) | 높음 | 5회/분/사용자 |
| 인증 (로그인/가입) | 중간 | 5회/분/IP, 5회 실패 시 30분 잠금 |
| 일반 API | 낮음 | 30회/분/IP |

### 구현 옵션

| 방식 | 장점 | 단점 |
|------|------|------|
| **Upstash Redis** | 분산 환경 지원, 무료 티어 | 외부 의존성 |
| **메모리 Map** | 단순, 의존성 없음 | 단일 인스턴스만, 재시작 시 초기화 |
| **DB 테이블** | 영구 기록, 감사 로그 겸용 | 매 요청 DB 쿼리 |

---

## 8. 데이터 보호

### 민감 정보 마스킹

```typescript
// 로그에서 자동 마스킹
// 이메일: test@example.com → t***@e***.com
// UUID: 12345678-1234-... → 1234****-****-...
// 전화번호: 010-1234-5678 → 010-****-5678
```

### 입력값 검증

| 레이어 | 검증 내용 |
|--------|----------|
| **클라이언트** | UX 피드백용 (이것만으로 불충분) |
| **서버** | 타입, 길이, 패턴 재검증 (필수) |
| **DB** | 제약조건, CHECK, RLS (최종 방어선) |

### 환경변수 관리 원칙

| 구분 | 저장 위치 | 접근 |
|------|----------|------|
| 클라이언트용 (`NEXT_PUBLIC_*`, `VITE_*`) | 호스팅 플랫폼 Env | 브라우저에 노출됨 (공개 키만) |
| 서버용 (API 키, 시크릿) | 호스팅 플랫폼 Env (서버 전용) | 서버에서만 접근 |
| Edge Function용 | Supabase Secrets / 플랫폼 Secrets | 함수 런타임에서만 접근 |

---

## 9. 에러 처리 정책

### 원칙

```typescript
// 사용자에게: 일반 메시지만
// 개발자에게: 상세 에러는 console.error + 모니터링(Sentry)

// ❌
alert('실패: ' + error.message);  // 내부 정보 노출

// ✅
console.error('[기능명] 에러:', error);
alert('처리에 실패했습니다. 다시 시도해주세요.');
```

### 에러 응답 표준화

```typescript
// API 에러 응답 — 내부 정보 노출 금지
return Response.json(
  { error: 'Something went wrong' },  // 일반 메시지
  { status: 500 }
);
// error.message, stack trace 절대 포함하지 않음
```

---

## 10. 인시던트 대응

### API 키 유출 시

1. **즉시** 키 재발급 (로테이션)
2. 영향 받은 서비스 점검 (사용자 데이터, 비밀번호 등)
3. 호스팅 플랫폼 + DB Secrets 환경변수 동기 업데이트
4. 관련 로그 분석 (악용 여부)
5. 재배포

### `.env` 파일 git 커밋 시

1. `git rm --cached <파일>` 로 추적 제거
2. `.gitignore` 패턴 보강 (`.env*` 포괄 패턴)
3. 노출된 시크릿 **전부** 즉시 로테이션
4. 필요 시 `BFG Repo-Cleaner`로 git 히스토리 정리
5. Private repo라도 **즉시 로테이션** — 히스토리에 값이 영구 잔존

### 의존성 취약점

```bash
# 정기 확인 (월 1회)
npm audit

# critical/high는 즉시 패치
npm audit fix

# 자동화: GitHub Dependabot 또는 Snyk 연동 권장
```

---

## 보안 체크리스트

### 배포 전 (매번)

- [ ] `npm audit` 취약점 critical/high 0개
- [ ] 환경변수 설정 확인 (프로덕션 키가 맞는지)
- [ ] 에러 메시지에 민감 정보 노출 없음
- [ ] 새로 추가한 API에 인증/Rate Limit 적용 확인
- [ ] CSP 변경했으면 결제/로그인/공유 전체 테스트

### 정기 점검 (월 1회)

- [ ] npm 패키지 업데이트 + audit
- [ ] RLS 정책 검토 (새 테이블에 누락 없는지)
- [ ] API/Edge Function 로그 이상 징후
- [ ] 에러 모니터링 리포트 검토

### 새 기능 개발 시

- [ ] 사용자 입력은 서버에서 재검증했는가?
- [ ] SQL은 파라미터 바인딩을 쓰는가?
- [ ] HTML 출력 시 이스케이프 처리했는가? (XSS)
- [ ] 새 테이블에 RLS 정책을 추가했는가?
- [ ] 새 API에 인증이 필요한가? 적용했는가?
- [ ] 새 외부 도메인을 CSP에 추가했는가?

---

## 참고 자료

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Supabase Security Best Practices](https://supabase.com/docs/guides/auth/security)
- [MDN Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)

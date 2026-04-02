# 나다운세 보안 가이드

> **최종 업데이트**: 2026-02-25
> **보안 감사 수행**: Claude Opus 4.6
> **적용 환경**: Production + Staging

---

## 목차

1. [보안 아키텍처 개요](#1-보안-아키텍처-개요)
2. [적용된 보안 조치](#2-적용된-보안-조치)
3. [CORS 정책](#3-cors-정책)
4. [보안 헤더](#4-보안-헤더)
5. [Content Security Policy (CSP)](#5-content-security-policy-csp)
6. [인증 및 권한](#6-인증-및-권한)
7. [데이터 보호](#7-데이터-보호)
8. [에러 처리 정책](#8-에러-처리-정책)
9. [향후 적용 TODO](#9-향후-적용-todo)
10. [보안 체크리스트](#10-보안-체크리스트)

---

## 1. 보안 아키텍처 개요

### 기술 스택별 보안 책임

```
┌─────────────────────────────────────────────────────────────────┐
│                        클라이언트 (React)                        │
│  - CSP 적용 (XSS 방지)                                          │
│  - 민감 정보 마스킹 (logger.ts)                                  │
│  - 에러 메시지 일반화                                            │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Vercel (호스팅/CDN)                         │
│  - HTTPS 강제 적용                                               │
│  - 보안 헤더 (X-Frame-Options, X-Content-Type-Options 등)       │
│  - CSP 헤더 전송                                                 │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                 Supabase Edge Functions (32개)                   │
│  - CORS 화이트리스트 적용                                        │
│  - JWT 인증 검증                                                 │
│  - RLS (Row Level Security) 적용                                │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Supabase PostgreSQL                           │
│  - RLS 정책 (26개)                                               │
│  - 암호화된 연결 (SSL)                                           │
│  - Service Role Key 분리                                         │
└─────────────────────────────────────────────────────────────────┘
```

### 환경 분리

| 환경 | Supabase Project ID | 용도 |
|------|---------------------|------|
| **Production** | `kcthtpmxffppfbkjjkub` | nadaunse.com |
| **Staging** | `hyltbeewxaqashyivilu` | 테스트/미리보기 |

---

## 2. 적용된 보안 조치

### 2026-01-21 보안 감사 결과

| # | 항목 | 상태 | 커밋 해시 | 설명 |
|---|------|------|-----------|------|
| 1 | 하드코딩된 시크릿 제거 | ✅ 완료 | - | 환경변수로 이전 |
| 2 | build 폴더 Git 제외 | ✅ 완료 | - | `.gitignore` 추가 |
| 3 | CORS 화이트리스트 | ✅ 완료 | `e6ae360d` | 32개 Edge Function 적용 |
| 4 | npm 취약점 해결 | ✅ 완료 | `68964614` | 6개 → 0개 |
| 5 | 보안 헤더 추가 | ✅ 완료 | `26fd8539` | 5개 헤더 |
| 6 | CSP 정책 추가 | ✅ 완료 | `d6271279` | XSS 방지 |
| 7 | 에러 메시지 보안 | ✅ 완료 | `a7b0e8cb` | 상세 에러 숨김 |

### 2026-02-25 보안 감사 결과

| # | 항목 | 상태 | 커밋 해시 | 설명 |
|---|------|------|-----------|------|
| 1 | `.env.local.staging.backup` git 추적 제거 | ✅ 완료 | `5955051e` | `VITE_KAKAO_AUTH_SECRET` 노출 파일 제거 |
| 2 | `.gitignore` 포괄 패턴 적용 | ✅ 완료 | `5955051e` | `.env*` 패턴으로 모든 환경파일 커버 |
| 3 | `VITE_KAKAO_AUTH_SECRET` 로테이션 | ✅ 완료 | - | 새 시크릿 생성 + 카카오 사용자 750명 비밀번호 마이그레이션 |
| 4 | Vercel 환경변수 동기화 | ✅ 완료 | - | production/preview/development 3개 환경 업데이트 |

#### 인시던트 상세: `.env` 파일 git 노출

**발견**: `.env.local.staging.backup` 파일이 git에 커밋되어 `VITE_KAKAO_AUTH_SECRET=nadaunse_secret_2025` 노출
**원인**: `.gitignore`의 `.env*.local` 패턴이 `.backup`으로 끝나는 파일을 커버하지 못함
**영향**: 리포지토리 접근 권한이 있는 사용자가 카카오 로그인 비밀번호 생성 패턴(`kakao_{id}_{secret}`)을 알 수 있음
**대응**:
1. `git rm --cached` 로 추적 제거
2. `.gitignore`를 `.env` / `.env.*` 포괄 패턴으로 변경
3. 새 시크릿 생성 후 Supabase Auth에서 카카오 사용자 750명 비밀번호 일괄 업데이트
4. Vercel 전 환경(production/preview/development) 환경변수 업데이트
5. 재배포 트리거

**잔존 위험**: git 히스토리에 이전 시크릿 값 잔존 (private repo이므로 즉각적 위험은 낮음). 추후 `git filter-branch` 또는 BFG Repo-Cleaner로 히스토리 정리 권장.

#### 추가 발견: git 히스토리 내 Vercel OIDC 토큰

커밋 `5782a9c6`에 `.env.production.check` 파일이 기록됨 (이후 `507d3aec`에서 삭제). Vercel OIDC JWT 토큰이 포함되어 있으나, 토큰은 단시간 만료되므로 실질적 위험은 낮음.

---

## 3. CORS 정책

### 허용된 Origin

```typescript
// supabase/functions/server/cors.ts

const ALLOWED_ORIGINS = [
  'https://nadaunse.com',
  'https://www.nadaunse.com',
  'https://staging.nadaunse.com',
];

// localhost는 모든 포트 허용 (개발 환경)
// http://localhost:*
```

### 적용된 Edge Functions (32개)

| 카테고리 | Functions |
|----------|-----------|
| **AI 생성** | generate-content-answers, generate-saju-answer, generate-tarot-answer, generate-saju-preview, generate-tarot-preview, generate-free-preview, generate-master-content, generate-image-prompt, generate-thumbnail |
| **주간 보고서** | generate-weekly-reports-batch, generate-weekly-report, send-report-alimtalk, check-owner-status |
| **쿠폰** | apply-coupon-to-order, get-available-coupons, issue-revisit-coupon, issue-welcome-coupon |
| **결제** | process-payment, process-refund, payment-webhook |
| **사용자** | users, master-content |
| **알림** | send-alimtalk |
| **모니터링** | sentry-slack-webhook, ga-stats |
| **SEO** | generate-sitemap, index-now |
| **유틸리티** | get-manse-data, cleanup-unconfirmed-tags |
| **소유자 확인** | check-owner-phone, verify-owner-code |

### CORS 검증 방법

```bash
# 허용된 Origin 테스트
curl -I -X OPTIONS "https://[project-id].supabase.co/functions/v1/users" \
  -H "Origin: https://nadaunse.com" \
  -H "Access-Control-Request-Method: POST"
# 결과: Access-Control-Allow-Origin: https://nadaunse.com ✅

# 차단된 Origin 테스트
curl -I -X OPTIONS "https://[project-id].supabase.co/functions/v1/users" \
  -H "Origin: https://evil-site.com" \
  -H "Access-Control-Request-Method: POST"
# 결과: Access-Control-Allow-Origin 헤더 없음 ✅
```

---

## 4. 보안 헤더

### vercel.json 설정

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-XSS-Protection", "value": "1; mode=block" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "Permissions-Policy", "value": "camera=(), microphone=(), geolocation=()" }
      ]
    }
  ]
}
```

### 헤더별 효과

| 헤더 | 값 | 방어 대상 |
|------|-----|----------|
| **X-Frame-Options** | DENY | 클릭재킹 공격 (iframe 삽입 차단) |
| **X-Content-Type-Options** | nosniff | MIME 타입 스니핑 공격 |
| **X-XSS-Protection** | 1; mode=block | 반사형 XSS 공격 (레거시 브라우저) |
| **Referrer-Policy** | strict-origin-when-cross-origin | 리퍼러 정보 유출 |
| **Permissions-Policy** | camera=(), microphone=(), geolocation=() | 불필요한 브라우저 권한 차단 |

---

## 5. Content Security Policy (CSP)

### 전체 정책

```
default-src 'self';
script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: https://cdn.iamport.kr https://*.iamport.kr https://*.portone.io https://developers.kakao.com https://*.kakaocdn.net https://*.sentry.io https://www.googletagmanager.com https://wcs.pstatic.net https://ssl.pstatic.net;
style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net;
img-src 'self' data: blob: https://*.supabase.co https://*.kakaocdn.net https://wcs.pstatic.net;
font-src 'self' data: https://cdn.jsdelivr.net;
connect-src 'self' https://*.supabase.co https://*.supabase.in wss://*.supabase.co https://*.sentry.io https://kauth.kakao.com https://kapi.kakao.com https://*.iamport.kr https://*.portone.io https://www.google-analytics.com https://region1.google-analytics.com https://cdn.jsdelivr.net https://wcs.pstatic.net https://*.naver.com;
frame-src https://*.iamport.kr https://*.portone.io https://*.kakao.com https://kauth.kakao.com https://*.kakaopay.com https://*.danal.co.kr https://*.teledit.com https://*.inicis.com https://*.toss.im;
media-src 'self';
object-src 'none';
base-uri 'self';
form-action 'self' https://kauth.kakao.com https://*.kakaopay.com https://*.iamport.kr https://*.portone.io https://sharer.kakao.com;
worker-src 'self' blob:;
```

### 지시문별 설명

| 지시문 | 허용 소스 | 이유 |
|--------|----------|------|
| **script-src** | self, iamport, portone, kakao, sentry, gtm, naver | 결제 SDK, 카카오 SDK, 에러 모니터링, 애널리틱스 |
| **connect-src** | supabase, sentry, kakao, iamport, portone, GA, naver | API 호출, 실시간 연결, 인증, 애널리틱스 |
| **frame-src** | iamport, portone, kakao, kakaopay, danal, **teledit**, inicis, toss | 결제창 iframe (⚠️ 다날은 `teledit.com` 도메인도 사용) |
| **form-action** | self, kakao, **kakaopay**, iamport, portone, **sharer.kakao.com** | 결제 redirect + 카카오톡 공유 (PC는 form submit 사용) |
| **img-src** | supabase, kakaocdn, naver | 썸네일 이미지, 프로필 사진, 애널리틱스 |
| **object-src** | none | Flash/Plugin 완전 차단 |

### 주의사항

- `'unsafe-inline'`, `'unsafe-eval'`: React/Vite 빌드 호환성을 위해 필요
- 향후 nonce 기반 CSP로 강화 가능

### ⚠️ 결제 CSP 장애 사례 (2026-01-21 ~ 2026-02-12)

CSP 도입 시 결제 도메인 2개가 누락되어 **약 3주간 결제 장애** 발생:
1. `*.teledit.com` (`frame-src`) - 다날이 체크아웃에 사용하는 파트너 도메인
2. `*.kakaopay.com` (`form-action`) - 카카오페이 모바일 redirect 시 form submit 대상

**교훈**: PG사 도메인은 공식 문서에 명시되지 않은 서브도메인/파트너 도메인이 있을 수 있으므로, CSP 변경 후 반드시 **모든 결제 수단 × 모든 환경(PC/모바일)** 조합을 테스트할 것.
상세: `DECISIONS.md` → "2026-02-12 CSP 결제 장애 해결"

---

## 6. 인증 및 권한

### 인증 방식

| 방식 | 제공자 | 용도 |
|------|--------|------|
| **카카오 OAuth** | Supabase Auth + 커스텀 | 주 로그인 방식 |
| **구글 OAuth** | Supabase Auth | 보조 로그인 방식 |
| **JWT 토큰** | Supabase | API 인증 |

### 토큰 관리

```typescript
// 토큰 갱신 주기: 자동 (Supabase SDK)
// 세션 만료: 1시간 (설정 가능)
// Refresh Token: 7일
```

### RLS (Row Level Security)

- **적용 테이블**: 9개
- **정책 수**: 26개
- **원칙**: 사용자는 자신의 데이터만 접근 가능

```sql
-- 예시: orders 테이블
CREATE POLICY "Users can view own orders"
ON orders FOR SELECT
USING (auth.uid() = user_id);
```

---

## 7. 데이터 보호

### 민감 정보 마스킹

```typescript
// src/lib/logger.ts

// 프로덕션에서 자동 마스킹되는 패턴:
// - 이메일: test@example.com → t***@e***.com
// - UUID: 12345678-1234-... → 1234****-****-...
// - 전화번호: 010-1234-5678 → 010-****-5678
```

### 환경변수 관리

| 변수명 | 용도 | 저장 위치 |
|--------|------|----------|
| `VITE_SUPABASE_PROJECT_ID` | Supabase 연결 | Vercel Env |
| `VITE_SUPABASE_ANON_KEY` | 클라이언트 인증 | Vercel Env |
| `VITE_KAKAO_AUTH_SECRET` | 카카오 인증 비밀번호 생성 | Vercel Env |
| `SUPABASE_SERVICE_ROLE_KEY` | Edge Function 전용 | Supabase Secrets |
| `OPENAI_API_KEY` | AI 생성 | Supabase Secrets |
| `INDEXNOW_API_KEY` | IndexNow URL 제출 | Supabase Secrets |
| `SAJU_API_KEY` | 사주 API 호출 | Supabase Secrets |
| `TALKDREAM_AUTH_TOKEN` | 카카오 알림톡 발송 | Supabase Secrets |
| `PORTONE_API_KEY` | 결제 검증 | Supabase Secrets |
| `PORTONE_API_SECRET` | 결제 검증 | Supabase Secrets |
| `SLACK_WEBHOOK_URL` | Sentry 알림 전달 | Supabase Secrets |
| `GOOGLE_API_KEY` | Gemini AI | Supabase Secrets |

### 하드코딩 금지 항목

- ❌ API 키
- ❌ 시크릿 키
- ❌ 데이터베이스 URL
- ❌ 프로젝트 ID

---

## 8. 에러 처리 정책

### 원칙

1. **사용자에게**: 일반적인 에러 메시지만 표시
2. **개발자에게**: 상세 에러는 console.error로 기록
3. **모니터링**: Sentry로 에러 자동 수집

### 수정된 패턴

```typescript
// ❌ 잘못된 예시 (수정 전)
alert('로그인 실패: ' + error.message);

// ✅ 올바른 예시 (수정 후)
console.error('로그인 에러:', error);
alert('로그인에 실패했습니다. 다시 시도해주세요.');
```

### 수정된 파일

- `ExistingAccountPageNew.tsx`
- `LoginPageNew.tsx`
- `MasterContentDetail.tsx`
- `MasterContentQuestions.tsx`

---

## 9. 향후 적용 TODO

### 높은 우선순위

#### 1. Rate Limiting (API 요청 제한)

**목적**: DDoS 방지, API 남용 방지, 비용 보호

**적용 대상** (우선순위순):

| Edge Function | 위험도 | 이유 | 권장 제한 |
|--------------|--------|------|----------|
| `generate-content-answers` | 🔴 높음 | OpenAI 비용 발생 | 10회/분/사용자 |
| `generate-saju-answer` | 🔴 높음 | Claude 비용 발생 | 10회/분/사용자 |
| `generate-tarot-answer` | 🔴 높음 | Claude 비용 발생 | 10회/분/사용자 |
| `send-alimtalk` | 🔴 높음 | TalkDream 과금 | 5회/분/사용자 |
| `users` | 🟡 중간 | 브루트포스 방지 | 30회/분/IP |

**구현 방법 옵션**:

```typescript
// 옵션 1: Upstash Redis (권장)
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, "60 s"),
});

// 옵션 2: 메모리 기반 (단일 인스턴스만)
const requestCounts = new Map<string, { count: number; resetAt: number }>();

// 옵션 3: Supabase 테이블 기반
// rate_limits 테이블에 요청 기록 후 조회
```

**예상 비용**: Upstash 무료 티어 (10,000 요청/일)

---

#### 2. CSP 강화 (Nonce 기반)

**현재**: `'unsafe-inline'`, `'unsafe-eval'` 허용
**목표**: Nonce 기반 스크립트 허용

```typescript
// 서버에서 nonce 생성
const nonce = crypto.randomBytes(16).toString('base64');

// CSP 헤더
`script-src 'self' 'nonce-${nonce}'`

// HTML에 nonce 적용
<script nonce={nonce}>...</script>
```

**난이도**: 높음 (Vite 빌드 설정 변경 필요)

---

#### 3. Subresource Integrity (SRI)

**목적**: CDN 스크립트 변조 감지

```html
<!-- 현재 -->
<script src="https://cdn.iamport.kr/v1/iamport.js"></script>

<!-- SRI 적용 후 -->
<script
  src="https://cdn.iamport.kr/v1/iamport.js"
  integrity="sha384-..."
  crossorigin="anonymous">
</script>
```

---

### 중간 우선순위

#### 4. 로그인 시도 제한

```typescript
// 5회 실패 시 30분 잠금
const MAX_ATTEMPTS = 5;
const LOCKOUT_DURATION = 30 * 60 * 1000; // 30분
```

#### 5. 세션 관리 강화

- 동시 로그인 제한
- 비활성 세션 자동 만료
- 로그아웃 시 모든 세션 종료 옵션

#### 6. 보안 로깅

```typescript
// 감사 로그 테이블
interface SecurityLog {
  event_type: 'login' | 'logout' | 'password_change' | 'api_access';
  user_id: string;
  ip_address: string;
  user_agent: string;
  timestamp: Date;
  success: boolean;
}
```

---

### 낮은 우선순위

#### 7. CAPTCHA 적용

- 로그인/회원가입에 reCAPTCHA v3 적용
- 봇 트래픽 차단

#### 8. 2FA (2단계 인증)

- 관리자 계정에 TOTP 적용
- 일반 사용자는 선택적 적용

#### 9. 정기 보안 감사

- 분기별 npm audit 실행
- 연간 침투 테스트

---

## 10. 보안 체크리스트

### 배포 전 체크리스트

- [ ] `npm audit` 취약점 0개 확인
- [ ] 환경변수 설정 확인 (Vercel, Supabase)
- [ ] CSP 헤더 적용 확인
- [ ] CORS 화이트리스트 확인
- [ ] 에러 메시지에 민감 정보 노출 없음 확인

### 정기 점검 항목 (월간)

- [ ] npm 패키지 업데이트
- [ ] Supabase RLS 정책 검토
- [ ] Edge Function 로그 이상 징후 확인
- [ ] Sentry 에러 리포트 검토

### 인시던트 대응

1. **의심스러운 활동 감지 시**
   - Supabase Dashboard > Logs 확인
   - 해당 IP/사용자 차단 검토

2. **API 키 유출 시**
   - 즉시 키 재발급 (로테이션)
   - 영향 받은 서비스 점검 (사용자 비밀번호 마이그레이션 등)
   - 관련 로그 분석
   - Vercel + Supabase Secrets 환경변수 동기 업데이트

3. **`.env` 파일 git 커밋 시**
   - `git rm --cached <파일>` 로 추적 제거
   - `.gitignore` 패턴 보강 (`.env*` 포괄 패턴 권장)
   - 노출된 시크릿 즉시 로테이션
   - 필요 시 `BFG Repo-Cleaner` 또는 `git filter-branch`로 히스토리 정리

---

## 참고 자료

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Supabase Security Best Practices](https://supabase.com/docs/guides/auth/security)
- [Vercel Security Headers](https://vercel.com/docs/concepts/edge-network/headers)
- [MDN Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)

---

**문서 작성**: Claude Opus 4.5 (초안), Claude Opus 4.6 (2026-02-25 업데이트)
**최종 감사**: 2026-02-25 시크릿 노출 감사 + 로테이션 완료

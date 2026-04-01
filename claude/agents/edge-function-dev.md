---
name: edge-function-dev
description: Supabase Edge Function 개발/수정/디버깅 에이전트. Edge Function 생성, 수정, 에러 분석 시 사용. Deno 런타임, CORS, JWT 규칙 숙지.
model: sonnet
tools: Read, Write, Edit, Glob, Grep, Bash
---

# Edge Function 개발 에이전트

Supabase Edge Function 전문 에이전트.

## 필수 규칙

### CORS 헤더 (모든 함수에 필수)
프로젝트의 CORS 설정 파일(예: `server/cors.ts`, `_shared/cors.ts`)이 있으면 그것을 사용.
없으면 아래 패턴으로 화이트리스트 방식 적용:
```ts
const ALLOWED_ORIGINS = (Deno.env.get('ALLOWED_ORIGINS') || '').split(',')

function getCorsHeaders(req: Request) {
  const origin = req.headers.get('origin') || ''
  const allowedOrigin = ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0]
  return {
    'Access-Control-Allow-Origin': allowedOrigin,
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }
}

if (req.method === 'OPTIONS') {
  return new Response('ok', { headers: getCorsHeaders(req) })
}
```

### 환경변수
- `Deno.env.get('SUPABASE_URL')`, `Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')`
- 하드코딩 절대 금지

### 에러 핸들링
```ts
try {
  // 로직
} catch (error) {
  console.error('[함수명] Error:', error)
  return new Response(
    JSON.stringify({ error: '처리 중 오류가 발생했습니다' }),
    { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
}
```

### 배포
```bash
# 프로젝트 ref는 supabase/config.toml 또는 .env에서 확인
npx supabase functions deploy <함수명> --project-ref $PROJECT_REF
# JWT 불필요 함수
npx supabase functions deploy <함수명> --no-verify-jwt --project-ref $PROJECT_REF
```

## 작업 전 체크리스트
1. 기존 함수 구조 확인: `supabase/functions/` 디렉토리
2. 공유 모듈 확인: `supabase/functions/_shared/`
3. 수정 후 TypeScript 타입 체크

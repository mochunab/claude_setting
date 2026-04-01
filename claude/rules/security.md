# 보안 규칙 (모든 코딩 작업에 자동 적용)

## 절대 금지
- API 키, 시크릿, 토큰 하드코딩 → 환경변수 필수
- `error.message` 사용자 직접 노출 → 일반 메시지만 표시, 상세는 `console.error`
- `.env` 파일 git 커밋 → `.gitignore` 필수
- 외부 이미지/스크립트 URL 무분별 추가 (CSP 위반 가능)

## 입력값 검증
- 사용자 입력은 서버에서 재검증 (클라이언트 검증만으로 불충분)
- SQL 파라미터 바인딩 필수 (문자열 연결 금지)
- HTML 출력 시 이스케이프 처리 (XSS 방지)

## Edge Function / API 엔드포인트
- CORS: 허용 Origin 화이트리스트 방식 (`*` 금지)
- 인증 필요한 엔드포인트는 JWT/세션 검증 필수
- Rate limiting 고려

## 에러 처리
```tsx
// ✅
console.error('[기능명] 에러:', error);
alert('처리에 실패했습니다. 다시 시도해주세요.');

// ❌
alert('실패: ' + error.message);  // 내부 정보 노출
```

## 인시던트 대응
- API 키 유출 시: 즉시 로테이션 → 호스팅 플랫폼 Secrets 동기 업데이트
- .env 커밋 시: `git rm --cached` → `.gitignore` 보강 → 시크릿 로테이션
- 의존성 취약점: `npm audit` 정기 확인 → critical/high 즉시 패치

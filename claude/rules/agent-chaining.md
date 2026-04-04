# 에이전트 체이닝 규칙

## 원칙
- 체인은 **제안**이지 강제가 아님 — 에이전트 완료 후 "다음: [에이전트명]을 실행할까요?" 형태로 제안
- 이전 에이전트의 출력을 다음 에이전트 프롬프트에 요약 포함 (전체 복사 금지)
- 사용자가 중간에 끊으면 즉시 중단
- [code-searcher]는 진입점이 기본이지만, 사용자가 대상 파일/위치를 이미 알고 있으면 스킵

## 체인 정의

### 범용 개발 체인 (코드 변경 시)
[code-searcher] → (직접 수정) → qa-tester → deploy-checker
- code-searcher 완료 → 영향 범위 공유 후 직접 수정 진행
- 수정 완료 → "qa-tester로 동작 검증할까요?"
- qa-tester 통과 → "deploy-checker로 배포 점검할까요?"

### Edge Function 체인
[code-searcher] → edge-function-dev → qa-tester → deploy-checker
- Supabase Edge Function 작업일 때만 적용
- edge-function-dev 완료 → "qa-tester로 동작 검증할까요?"

### UI 체인 (UI 변경 시)
[code-searcher] → (직접 수정) → ui-reviewer → qa-tester → deploy-checker
- 수정 완료 → "ui-reviewer로 디자인 검토할까요?"
- ui-reviewer 지적사항 있음 → 수정 후 qa-tester 제안
- ui-reviewer 통과 → "qa-tester로 브라우저 검증할까요?"

### 비즈니스 체인 (기획 시)
growth-strategist → feature-planner → content-planner
- growth-strategist 완료 → "feature-planner로 기능 스펙을 구체화할까요?"
- feature-planner 완료 → "content-planner로 런칭 콘텐츠를 기획할까요?"

### 실패 복구 체인
deploy-checker 실패 → code-searcher (원인 탐색)
qa-tester 실패    → code-searcher (버그 위치 탐색)
- 실패 시 에러 내용을 code-searcher에 전달하여 원인 파일/라인 특정

## 컨텍스트 전달 형식

이전 에이전트 → 다음 에이전트로 넘길 때:

```
[이전 에이전트: {이름}]
결과: {1~3줄 요약}
핵심 파일: {파일 경로 목록}
주의사항: {있으면}
```

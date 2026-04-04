# Global Rules

## 응답 스타일
- 간결하게 답변. 코멘트는 로직이 자명하지 않을 때만
- 한국어 기본. 코드/커밋 메시지는 영어 OK

## 작업 방식
- 수정 전 기존 코드/컴포넌트 먼저 확인 — 중복 생성 방지
- 변경 시 해당 파일만 보지 말고 전체 흐름(입력→처리→저장→출력) 점검
- 객체지향적 모듈화 우선 — 결합도↓ 응집도↑

## 에이전트 워크플로우
- 배포 전 → `deploy-checker` 에이전트로 점검
- UI/디자인 변경 후 → `ui-reviewer` 에이전트로 리뷰
- Edge Function 작업 → `edge-function-dev` 에이전트 활용
- 코드 위치 파악 → `code-searcher` 에이전트로 탐색
- 에이전트 체이닝 → `rules/agent-chaining.md` 참조

## 커밋
- `<type>: <description>` — feat, fix, docs, style, refactor, test, chore

## 문서
- CLAUDE.md는 200줄 이내 — 코드에서 유추 가능한 것은 적지 않음
- 글로벌 = 공통 원칙, 프로젝트별 CLAUDE.md = 오버라이드/확장

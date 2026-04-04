# Harness Engineering 참고서

> **"모델이 아니라 환경이 결과를 결정한다"**
> 어떤 AI/사람이 코딩하든 동일한 품질의 결과물을 보장하는 통제 메커니즘 설계 방법론

---

## 1. 핵심 개념

### 하네스 엔지니어링이란?

AI 에이전트(또는 개발자)에게 **좋은 프롬프트를 주는 것**이 아니라, **틀릴 수 없는 환경을 만드는 것**.

| 접근 | 예시 | 강제력 |
|------|------|--------|
| 프롬프트 엔지니어링 | "any 타입 쓰지 마" | 권고 (advisory) — 무시 가능 |
| **하네스 엔지니어링** | ESLint `no-explicit-any: error` | **강제 (deterministic)** — 커밋 자체가 차단 |

### 멱등성 (Idempotency)

> 같은 요구사항 → 어떤 도구(Claude, Cursor, 사람)가 작업하든 → **동일한 품질의 결과물**

린터 + pre-commit hook + 자동 검증이 갖춰지면, 누가 코딩하든 규칙을 벗어날 수 없다.

---

## 2. 하네스의 6가지 구성 요소

### 2-1. CLAUDE.md (지침 문서)

매 세션마다 AI에 주입되는 프로젝트 규칙. **권고사항**이므로 다른 레이어와 결합해야 효력 발생.

**작성 원칙**:
- 코드에서 유추 가능한 것은 적지 않음
- 200줄 이내 유지 (너무 길면 AI가 규칙을 놓침)
- 정기적으로 리뷰하여 불필요한 규칙 제거

### 2-2. 린터 (ESLint / Prettier)

CLAUDE.md의 규칙을 **코드 레벨에서 강제**하는 핵심 도구.

```
권고 → 강제 승격 예시:

CLAUDE.md: "any 타입 금지"           → ESLint: @typescript-eslint/no-explicit-any
CLAUDE.md: "Tailwind 폰트 클래스 금지" → ESLint: no-restricted-syntax (커스텀 셀렉터)
CLAUDE.md: "=== 사용"                → ESLint: eqeqeq
CLAUDE.md: "eval 금지"               → ESLint: no-eval, no-implied-eval
```

**기존 코드 전략**: 전체를 `warn`으로 설정 → 새 코드만 `--max-warnings=0`으로 차단.

### 2-3. Pre-commit Hook (커밋 게이트)

커밋 시점에 자동 검증. **staged 파일만** 린트하여 기존 코드에 영향 없음.

```
Husky (.husky/pre-commit)
  └→ lint-staged
       └→ eslint --max-warnings=0 (staged .ts/.tsx만)
```

### 2-4. Claude Code Hooks (실시간 피드백)

AI가 파일을 편집하는 **그 순간** 린트 실행. 문제를 커밋 전에 잡아냄.

```json
// .claude/settings.json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "command": "bash scripts/lint-hook.sh"
    }]
  }
}
```

**Hook 이벤트 종류**:
| 이벤트 | 시점 | 활용 예 |
|--------|------|---------|
| `PreToolUse` | 도구 실행 전 | 보호 파일 편집 차단 |
| `PostToolUse` | 도구 실행 후 | 자동 린트, 자동 포맷 |
| `SessionStart` | 세션 시작 시 | 컨텍스트 주입 |

### 2-5. 서브에이전트 (컨텍스트 격리)

탐색/연구를 별도 에이전트에 위임하여 **메인 컨텍스트 오염 방지**.

- 코드베이스 탐색 → `Explore` 에이전트
- 병렬 작업 → `worktree` 격리 모드
- 코드 리뷰 → 전문 리뷰 에이전트

### 2-6. MCP 서버 (외부 도구 연결)

Figma, Supabase, Vercel 등 외부 서비스를 AI가 직접 사용할 수 있게 연결.

---

## 3. 3중 방어 아키텍처

```
┌─────────────────────────────────────────────────┐
│  1층: 실시간 (Claude Code Hook)                   │
│  AI가 파일 편집할 때마다 자동 린트                    │
│  → 문제 발견 즉시 피드백                            │
├─────────────────────────────────────────────────┤
│  2층: 커밋 시점 (Pre-commit Hook)                  │
│  git commit 시 staged 파일만 린트                   │
│  → 경고 1개라도 있으면 커밋 차단                      │
├─────────────────────────────────────────────────┤
│  3층: 배포 전 (수동 검증)                           │
│  npm run verify                                   │
│  → ESLint + TypeScript + Vite Build 전체 검증      │
└─────────────────────────────────────────────────┘
```

---

## 4. 실전 적용 가이드

### 4-1. 도입 순서 (뒤에서 앞으로)

글의 핵심 인사이트: **검증부터 설계하고, 그 다음 통제를 만든다**.

```
Step 1: 이밸류에이션 설계
        "무엇이 올바른 결과인가?" 정의
        → 테스트, 빌드 검증, 품질 기준

Step 2: 린터/Hook 구축
        "올바르지 않은 결과를 어떻게 차단할 것인가?"
        → ESLint 규칙, pre-commit hook

Step 3: 코딩
        이 두 가지가 갖춰진 상태에서 코딩 시작
        → 어떤 AI/사람이든 일관된 결과
```

### 4-2. 기존 프로젝트에 점진적 적용

| 단계 | 행동 | 기존 코드 영향 |
|------|------|---------------|
| 1 | ESLint 설치, 모든 규칙 `warn` | 없음 |
| 2 | lint-staged에서 `--max-warnings=0` | 없음 (새 코드만) |
| 3 | Pre-commit hook 활성화 | 없음 (staged만) |
| 4 | 점진적으로 기존 코드 `warn` → `error` 승격 | 선택적 |

### 4-3. CPS 프레임워크 (기획 문서화)

아키텍처 결정을 기록할 때 **Context-Problem-Solution** 구조 사용:

```markdown
### [기능명]

**Context**: 어떤 상황/배경에서
**Problem**: 어떤 문제를 해결해야 하는데
**Solution**: 이런 방식으로 해결했다

**영향**: 변경된 파일/모듈
```

AI가 과거 결정의 **"왜"**를 이해하면, 충돌하는 코드를 덜 생성한다.

### 4-4. DDD 네이밍 강제

도메인 용어만 파일명에 사용 — AI가 생성하는 새 파일도 자동으로 도메인 언어를 따르게.

```
❌ restaurantListPage, TarotDetailView, PaymentListSection
✅ restaurants, tarot-reading, payments
```

린터로 파일명 규칙을 강제하면, 하위 클래스/메소드 이름도 자연스럽게 통일됨.

---

## 5. 컨텍스트 관리 전략

AI 에이전트의 **가장 큰 제약**은 컨텍스트 윈도우. 이를 효율적으로 관리하는 것이 하네스 엔지니어링의 숨은 핵심.

### 핵심 원칙

| 원칙 | 방법 |
|------|------|
| 작업 단위 분리 | 관련 없는 작업 사이에 `/clear` |
| 탐색 위임 | 서브에이전트로 탐색 → 메인 컨텍스트 보호 |
| 실패 시 리셋 | 2번 수정해도 안 되면 `/clear` 후 재시작 |
| 진행상황 기록 | 컨텍스트 소진 대비 progress 파일/커밋 메시지에 기록 |

### Explore → Plan → Code → Commit

```
1. Explore (Plan Mode)  → 파일 읽기, 질문, 구조 파악
2. Plan                 → 구현 계획 수립, 사용자 확인
3. Code (Normal Mode)   → 계획에 따라 구현 + 검증
4. Commit               → 변경사항 설명 + 커밋
```

---

## 6. 3-에이전트 아키텍처

Anthropic이 제시한 장기 실행 에이전트를 위한 레퍼런스 패턴.

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Initializer │ ──→ │  Generator   │ ──→ │  Evaluator   │
│  환경 세팅     │     │  점진적 구현   │     │  검증/평가     │
│  기능 명세 생성 │     │  아티팩트 남김  │     │  UI/DB/API    │
└──────────────┘     └──────────────┘     └──────────────┘
```

**왜 분리하는가?**
- 에이전트는 자기 작업을 **과대평가**하는 편향이 있음
- 별도 Evaluator가 객관적으로 검증해야 실제 품질 보장
- 기능 명세 파일로 "완료" 기준을 명시 → 조기 완료 선언 방지

---

## 7. 안티패턴 & 해결책

| 안티패턴 | 증상 | 해결 |
|---------|------|------|
| Kitchen Sink 세션 | 한 세션에 여러 무관한 작업 | `/clear`로 분리 |
| 무한 수정 루프 | 같은 문제를 3회 이상 수정 | 리셋 + 프롬프트 재설계 |
| CLAUDE.md 비대화 | 규칙 200줄 초과, AI가 놓침 | 코드 유추 가능한 것 삭제 |
| 검증 없는 신뢰 | 그럴듯하지만 작동 안 하는 코드 | 테스트/빌드 검증 필수 |
| 무한 탐색 | 범위 없이 코드베이스 탐색 | 서브에이전트 위임 |
| 권고만 있는 규칙 | CLAUDE.md에만 적혀있고 강제 없음 | 린터/Hook으로 승격 |

---

## 8. 참고 자료

- [Anthropic: Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Martin Fowler: Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)
- [Maily.so: 하네스 엔지니어링 실전 (스페이스와이)](https://maily.so/josh/posts/w6ov2vemrk5)
- [Claude Code Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices)

---

*최종 업데이트: 2026-03-27*

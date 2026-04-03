# Claude Setting

Claude Code 환경 설정 파일 저장소

## Quick Start

### macOS / Linux (Bash)

```bash
# 1. Clone
git clone https://github.com/mochunab/claude_setting.git ~/claude_setting

# 2. 설정 파일 복사
cp ~/claude_setting/claude/CLAUDE.md ~/.claude/CLAUDE.md
cp ~/claude_setting/claude/settings.json ~/.claude/settings.json
cp -r ~/claude_setting/claude/agents ~/.claude/agents
cp -r ~/claude_setting/claude/rules ~/.claude/rules
cp -r ~/claude_setting/claude/skills ~/.claude/skills
cp -r ~/claude_setting/claude/commands ~/.claude/commands
cp -r ~/claude_setting/claude/knowledge ~/.claude/knowledge

# 3. API keys (settings.local.json에 직접 설정)
# MCP 서버 설정은 ~/.claude/settings.local.json에 수동 구성
```

### Windows (PowerShell)

```powershell
git clone https://github.com/mochunab/claude_setting.git $env:USERPROFILE\claude_setting
Copy-Item $env:USERPROFILE\claude_setting\claude\CLAUDE.md $env:USERPROFILE\.claude\CLAUDE.md
Copy-Item $env:USERPROFILE\claude_setting\claude\settings.json $env:USERPROFILE\.claude\settings.json
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\agents $env:USERPROFILE\.claude\agents
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\rules $env:USERPROFILE\.claude\rules
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\skills $env:USERPROFILE\.claude\skills
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\commands $env:USERPROFILE\.claude\commands
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\knowledge $env:USERPROFILE\.claude\knowledge
# MCP 서버 설정은 %USERPROFILE%\.claude\settings.local.json에 수동 구성
```

---

## File Structure

```
claude_setting/
├── claude/
│   ├── CLAUDE.md                      # 글로벌 개발 원칙 (모든 프로젝트 자동 적용)
│   ├── agents/                        # 글로벌 에이전트 (8개)
│   │   ├── code-searcher.md
│   │   ├── deploy-checker.md
│   │   ├── edge-function-dev.md
│   │   ├── qa-tester.md
│   │   ├── ui-reviewer.md
│   │   ├── content-planner.md
│   │   ├── feature-planner.md
│   │   └── growth-strategist.md
│   ├── rules/                         # 글로벌 룰 (자동 적용)
│   │   ├── security.md
│   │   └── performance.md
│   ├── commands/                      # 슬래시 커맨드
│   │   └── thread.md
│   ├── skills/                        # 스킬 (4개)
│   │   ├── gemini-web-fetch/
│   │   ├── trend/
│   │   ├── ui-ux-pro-max/
│   │   └── vercel-react-best-practices/
│   ├── knowledge/                     # 지식 베이스 (범용 전략서 + 참조 데이터)
│   │   ├── 비즈니스/
│   │   │   ├── UNIVERSAL_GROWTH_FORMULA.md
│   │   │   ├── AARRR_FUNNEL_STRATEGY.md
│   │   │   └── PM_FRAMEWORKS.md
│   │   ├── 마케팅/
│   │   │   ├── VIRAL_FEATURE_STRATEGY.md
│   │   │   ├── SEO_전략서.md
│   │   │   └── GA_전략서.md
│   │   ├── 콘텐츠/
│   │   │   ├── VIRAL_CONTENT_MAKING_STRATEGY.md
│   │   │   ├── VIRAL_GROWTH_PLAYBOOK.md
│   │   │   └── ZALPHA_CHARACTER_GUIDE.md
│   │   ├── 개발/
│   │   │   ├── PERFORMANCE_OPTIMIZATION.md
│   │   │   ├── HARNESS_ENGINEERING.md
│   │   │   ├── CLAUDE_SETUP_STRATEGY.md
│   │   │   ├── TOKEN_OPTIMIZATION.md
│   │   │   ├── ONTOLOGY_GUIDE.md
│   │   │   └── SECURITY.md
│   └── settings.json
└── README.md
```

---

## CLAUDE.md (글로벌 개발 원칙)

모든 프로젝트에서 자동 적용되는 미니멀 행동 규칙 (22줄):

- **응답 스타일**: 간결 답변, 한국어 기본, 코멘트 최소화
- **작업 방식**: 수정 전 기존 코드 확인, 전체 흐름 점검, 모듈화 우선
- **에이전트 워크플로우**: 배포 전 deploy-checker, UI 변경 후 ui-reviewer 등 적시 스폰 힌트
- **커밋**: `<type>: <description>` 컨벤션
- **문서**: CLAUDE.md 200줄 제한

> 보안은 `rules/security.md`, 코딩 패턴은 `skills/*`에 위임. 프로젝트별 추가 규칙은 `프로젝트/CLAUDE.md`에 작성하면 글로벌과 합쳐서 적용됩니다.

---

## Plugins (5개 — 활성)

| Plugin | 용도 |
|--------|------|
| **feature-dev** | 코드 탐색, 아키텍처 설계, 코드 리뷰 에이전트 |
| **supabase** | Supabase DB 관리 (execute_sql, apply_migration 등) |
| **pr-review-toolkit** | PR 리뷰 — code-reviewer, silent-failure-hunter, code-simplifier, comment-analyzer, pr-test-analyzer, type-design-analyzer |
| **frontend-design** | 프론트엔드 UI 생성 |
| **vercel** | Vercel 배포/환경변수/스킬 (deploy, env, nextjs, ai-sdk 등 30+ 스킬 포함) |

> **비활성화된 플러그인**: `code-review` (pr-review-toolkit에 포함), `typescript-lsp` (내장 LSP 중복), `serena` (내장 도구 중복), `vercel-plugin` (vercel과 중복)

---

## Agents (8개 — 모든 프로젝트 범용)

### 개발 에이전트

| Agent | 용도 | 트리거 |
|-------|------|--------|
| **code-searcher** | 코드베이스 탐색, 영향도 분석 | "찾아줘", "어디서", "영향도" |
| **deploy-checker** | 배포 전 빌드/보안/환경변수 점검 | "배포 전 점검", "프로덕션 체크" |
| **edge-function-dev** | Supabase Edge Function 개발/디버깅 | Edge Function 관련 작업 |
| **qa-tester** | Playwright MCP 기반 브라우저 QA 테스트 | "QA", "테스트", "점검" |
| **ui-reviewer** | UI/디자인 리뷰 (스킬 자동 라우팅) | "UI 검사", "디자인 체크" |

### 비즈니스 에이전트

| Agent | 용도 | 트리거 |
|-------|------|--------|
| **content-planner** | 바이럴 콘텐츠 기획 — 감정 설계, 훅 카피, CTA | "콘텐츠 기획", "카피 써줘" |
| **feature-planner** | 바이럴 기능/제품 설계 — 심리 트리거, 공유 루프, 케이스 스터디 | "기능 기획", "바이럴 기능" |
| **growth-strategist** | 사업 성장 전략 — 본능 분석, AARRR 퍼널, 전환/잠금 설계 | "사업 전략", "성장 설계" |

---

## Rules (자동 적용)

| Rule | 역할 |
|------|------|
| **security.md** | 보안 기본 원칙 — 시크릿 관리, 입력검증, 에러처리, CORS, 인시던트 대응 |
| **performance.md** | 성능 기본 원칙 — 미들웨어 경량화, 캐시 레이어, 병렬화, staleTimes, 로딩 전략 |

> 모든 코딩 작업 시 자동으로 로드됩니다. 프로젝트별 추가 Rules는 `프로젝트/.claude/rules/`에 배치.

---

## Skills (4개)

| Skill | 용도 |
|-------|------|
| **ui-ux-pro-max** | UI/UX 디자인 인텔리전스 (67 styles, 96 palettes, 57 font pairings, 13 stacks) |
| **vercel-react-best-practices** | React/Next.js 성능 최적화 (Vercel Engineering 기반, 50+ 규칙) |
| **trend** | 멀티 플랫폼 트렌드 서칭 (X, 인스타, 스레드, 틱톡, 유튜브, 레딧) |
| **gemini-web-fetch** | WebFetch 폴백 (Gemini 활용) |

> 나머지 스킬(frontend-patterns, backend-patterns, postgres-patterns 등)은 플러그인(vercel, feature-dev 등)에 내장되어 제공됩니다.

---

## Commands (슬래시 커맨드)

| 커맨드 | 용도 |
|--------|------|
| `/thread` | 스레드 바이럴 글 자동 생성 (본글 + 댓글 구조) |

---

## Knowledge Base

범용 전략서 + 참조 데이터. 에이전트가 직접 경로로 참조한다.

### 비즈니스 전략서

| 파일 | 내용 | 참조 에이전트 |
|------|------|-------------|
| `비즈니스/UNIVERSAL_GROWTH_FORMULA.md` | 5단계 성장 엔진 (본능→훅→확산→전환→잠금), 7대 본능, PAS, Hook Model, Lock-in | growth-strategist |
| `비즈니스/AARRR_FUNNEL_STRATEGY.md` | AARRR 퍼널 설계, 단계별 지표 (MAU/LTV/K-Factor 등), PMF 공식 | growth-strategist |
| `비즈니스/PM_FRAMEWORKS.md` | PM 프레임워크 8종 — Lean Canvas, ICP, Value Proposition, OST, NSM 등 | growth-strategist, feature-planner |

### 마케팅 전략서

| 파일 | 내용 | 참조 에이전트 |
|------|------|-------------|
| `마케팅/VIRAL_FEATURE_STRATEGY.md` | 바이럴 기능 설계, 5가지 심리 트리거, 26개 케이스 스터디 | feature-planner |
| `마케팅/SEO_전략서.md` | SEO 체크리스트, 기술적 SEO, 콘텐츠 SEO | — |
| `마케팅/GA_전략서.md` | GA4 이벤트 설계, 전자상거래 퍼널, 디버깅 | — |

### 콘텐츠 전략서

| 파일 | 내용 | 참조 에이전트 |
|------|------|-------------|
| `콘텐츠/VIRAL_CONTENT_MAKING_STRATEGY.md` | 감정 설계, 8대 훅, 9개 카피 패턴, CTA, 템플릿 | content-planner |
| `콘텐츠/VIRAL_GROWTH_PLAYBOOK.md` | 바이럴 삼각형, 논란 설계, 밈 생산성, 7개 케이스 스터디 | content-planner |
| `콘텐츠/ZALPHA_CHARACTER_GUIDE.md` | Z/Alpha 세대 캐릭터 디자인 가이드 | — |

### 개발 전략서

| 파일 | 내용 |
|------|------|
| `개발/PERFORMANCE_OPTIMIZATION.md` | 웹 성능 최적화 — 캐시 4단계, 병렬화, HTTP 캐시, ErrorBoundary |
| `개발/HARNESS_ENGINEERING.md` | Claude Code 하네스 엔지니어링 — 3중 방어, 컨텍스트 관리 |
| `개발/CLAUDE_SETUP_STRATEGY.md` | .claude/ 폴더 구조 설계 — 레이어별 역할, 문서 작성법 |
| `개발/TOKEN_OPTIMIZATION.md` | 토큰 절약 전략 — 세션 관리, .claudeignore, 서브에이전트 |
| `개발/ONTOLOGY_GUIDE.md` | 온톨로지 설계 가이드 |
| `개발/SECURITY.md` | 보안 가이드 |

---

## MCP Servers

| MCP | 설명 | 설정 위치 |
|-----|------|----------|
| **Supabase** | DB 관리 | plugin (자동) |
| **Playwriter** | 브라우저 자동화 (Playwright) | Local MCP |

> MCP 서버 API 키는 `~/.claude.json` 또는 프로젝트별 `.claude.json`에 설정. **절대 git 커밋 금지.**

---

## Configuration

### settings.json
글로벌 설정 — 플러그인 활성화, 환경변수

### settings.local.json
기기별 로컬 설정 — MCP 서버 + API 키. **절대 git 커밋 금지.**

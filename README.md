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
│   ├── skills/                        # 스킬 (19개)
│   │   ├── accessibility-a11y/
│   │   ├── backend-patterns/
│   │   ├── clickhouse-io/
│   │   ├── coding-standards/
│   │   ├── find-skills/
│   │   ├── frontend-patterns/
│   │   ├── gemini-web-fetch/
│   │   ├── postgres-patterns/
│   │   ├── security-review/
│   │   ├── supanova-design-engine/
│   │   ├── supanova-full-output/
│   │   ├── supanova-premium-aesthetic/
│   │   ├── supanova-redesign-engine/
│   │   ├── tailwindcss-advanced-layouts/
│   │   ├── tdd-workflow/
│   │   ├── trend/
│   │   ├── ui-ux-pro-max/
│   │   ├── vercel-react-best-practices/
│   │   └── web-design-guidelines/
│   ├── knowledge/                     # 지식 베이스 (범용 전략서 + 참조 데이터)
│   │   ├── 비즈니스/
│   │   │   ├── UNIVERSAL_GROWTH_FORMULA.md    # 5단계 성장 엔진 (본능→훅→확산→전환→잠금)
│   │   │   ├── AARRR_FUNNEL_STRATEGY.md       # AARRR 퍼널 설계 + 단계별 지표
│   │   │   └── PM_FRAMEWORKS.md               # PM 프레임워크 8종 (Lean Canvas, ICP, VP, OST 등)
│   │   ├── 마케팅/
│   │   │   ├── VIRAL_FEATURE_STRATEGY.md      # 바이럴 기능 설계 + 26개 케이스 스터디
│   │   │   ├── SEO_전략서.md                   # SEO 체크리스트 + 기술적 SEO + 콘텐츠 SEO
│   │   │   └── GA_전략서.md                    # GA4 이벤트 설계 + 퍼널 분석
│   │   ├── 콘텐츠/
│   │   │   ├── VIRAL_CONTENT_MAKING_STRATEGY.md  # 콘텐츠 제작 — 감정 설계, 훅, CTA, 템플릿
│   │   │   ├── VIRAL_GROWTH_PLAYBOOK.md          # 바이럴 확산 — 논란 설계, 밈, 플랫폼 역학
│   │   │   └── ZALPHA_CHARACTER_GUIDE.md         # Z/Alpha 세대 캐릭터 가이드
│   │   ├── 개발/
│   │   │   ├── PERFORMANCE_OPTIMIZATION.md    # 웹 성능 최적화 — 캐시 4단계, 병렬화, HTTP
│   │   │   ├── HARNESS_ENGINEERING.md         # Claude Code 하네스 엔지니어링
│   │   │   ├── CLAUDE_SETUP_STRATEGY.md       # .claude/ 폴더 구조 설계 + 문서 작성법
│   │   │   ├── TOKEN_OPTIMIZATION.md          # 토큰 절약 전략
│   │   │   ├── ONTOLOGY_GUIDE.md              # 온톨로지 설계 가이드
│   │   │   └── SECURITY.md                    # 보안 가이드
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
| **feature-planner** | 바이럴 기능/제품 설계 — 심리 트리거, 공유 루프, 26개 케이스 | "기능 기획", "바이럴 기능" |
| **growth-strategist** | 사업 성장 전략 — 본능 분석, AARRR 퍼널, 전환/잠금 설계 | "사업 전략", "성장 설계", "퍼널 분석" |

### ui-reviewer 스킬 라우팅

ui-reviewer는 요청 유형에 따라 보유 디자인 스킬을 자동 선택하여 리뷰합니다:

| 요청 유형 | 적용 스킬 |
|-----------|-----------|
| 랜딩페이지 신규 | supanova-design-engine |
| 리디자인 | supanova-redesign-engine |
| 프리미엄 미학 | supanova-premium-aesthetic |
| 완전 출력 검증 | supanova-full-output |
| 일반 UI/UX | ui-ux-pro-max (기본) |
| 웹 디자인 가이드라인 | web-design-guidelines |
| 접근성 심층 검사 | accessibility-a11y |
| Tailwind 고급 레이아웃 | tailwindcss-advanced-layouts |
| React/Next.js | frontend-patterns |

---

## Rules (자동 적용)

| Rule | 역할 |
|------|------|
| **security.md** | 보안 기본 원칙 — 시크릿 관리, 입력검증, 에러처리, CORS, 인시던트 대응 |
| **performance.md** | 성능 기본 원칙 — 미들웨어 경량화, 캐시 레이어, 병렬화, staleTimes, 로딩 전략 |

> 모든 코딩 작업 시 자동으로 로드됩니다. 프로젝트별 추가 Rules는 `프로젝트/.claude/rules/`에 배치.

---

## Skills (19개)

### 디자인 (8개)

| Skill | 용도 |
|-------|------|
| **ui-ux-pro-max** | UI/UX 디자인 인텔리전스 (67 styles, 96 palettes, 57 font pairings, 13 stacks) |
| **supanova-design-engine** | 프리미엄 랜딩페이지 생성 (Tailwind CDN, 한국어 퍼스트) |
| **supanova-premium-aesthetic** | $150k 에이전시 수준 미학 — Double-Bezel 카드, 스프링 모션, 안티패턴 차단 |
| **supanova-redesign-engine** | 기존 랜딩페이지 진단 후 프리미엄 업그레이드 |
| **supanova-full-output** | AI 출력 생략 방지 — 플레이스홀더/스켈레톤 차단, 완전한 HTML 강제 |
| **web-design-guidelines** | Vercel 공식 웹 디자인 원칙 — 타이포, 컬러, 스페이싱, 레이아웃 기준 |
| **accessibility-a11y** | 웹 접근성 심층 검사 — WCAG, 스크린리더, 키보드, ARIA |
| **tailwindcss-advanced-layouts** | Tailwind 고급 레이아웃 — CSS Grid, 비대칭, 복잡한 반응형 패턴 |

### 프론트엔드 (3개)

| Skill | 용도 |
|-------|------|
| **frontend-patterns** | React, Next.js 컴포넌트/상태관리/퍼포먼스 패턴 |
| **vercel-react-best-practices** | React/Next.js 성능 최적화 (Vercel Engineering 기반, 50+ 규칙) |
| **coding-standards** | TypeScript/JavaScript/React/Node.js 코딩 표준 |

### 백엔드/DB (3개)

| Skill | 용도 |
|-------|------|
| **backend-patterns** | Node.js/Express/Next.js API 아키텍처, DB 최적화 |
| **postgres-patterns** | PostgreSQL 쿼리 최적화, 스키마 설계, 인덱싱, 보안 (Supabase 기반) |
| **clickhouse-io** | ClickHouse 분석 DB 패턴, 쿼리 최적화, 데이터 엔지니어링 |

### 보안/테스트 (2개)

| Skill | 용도 |
|-------|------|
| **security-review** | 인증, 입력검증, 시크릿, API, 결제 보안 체크리스트 |
| **tdd-workflow** | TDD 워크플로우 — 80%+ 커버리지, 단위/통합/E2E 테스트 |

### 콘텐츠/마케팅 (1개)

| Skill | 용도 |
|-------|------|
| **trend** | 멀티 플랫폼 트렌드 서칭 (X, 인스타, 스레드, 틱톡, 유튜브, 레딧) |

### 메타/유틸 (2개)

| Skill | 용도 |
|-------|------|
| **find-skills** | 스킬 마켓에서 새 스킬 검색/설치 (`npx skills find`) |
| **gemini-web-fetch** | WebFetch 폴백 (Gemini 활용) |

---

## Commands (슬래시 커맨드)

| 커맨드 | 용도 |
|--------|------|
| `/thread` | 스레드 바이럴 글 자동 생성 (본글 + 댓글 구조) |

> `/property`(청약 분석)는 개인정보 포함으로 `.gitignore` 처리. 로컬에만 존재.

---

## Knowledge Base

범용 전략서 + 참조 데이터. 에이전트가 직접 경로로 참조한다.

### 비즈니스 전략서

| 파일 | 내용 | 참조 에이전트 |
|------|------|-------------|
| `비즈니스/UNIVERSAL_GROWTH_FORMULA.md` | 5단계 성장 엔진 (본능→훅→확산→전환→잠금), 7대 본능, PAS, Hook Model, Lock-in, 소재 매트릭스 | growth-strategist |
| `비즈니스/AARRR_FUNNEL_STRATEGY.md` | AARRR 퍼널 설계, 단계별 지표 (MAU/LTV/K-Factor 등), PMF 공식, 퍼널 우선순위 판단 | growth-strategist |
| `비즈니스/PM_FRAMEWORKS.md` | PM 프레임워크 8종 — Lean Canvas, ICP, Value Proposition, OST, NSM, Pricing, GTM, Growth Loops | growth-strategist, feature-planner |

### 마케팅 전략서

| 파일 | 내용 | 참조 에이전트 |
|------|------|-------------|
| `마케팅/VIRAL_FEATURE_STRATEGY.md` | 바이럴 기능 설계, 5가지 심리 트리거, 26개 케이스 스터디, S/A/B 티어, 후킹 패턴 | feature-planner |
| `마케팅/SEO_전략서.md` | SEO 체크리스트, 기술적 SEO, 콘텐츠 SEO, 프로그래매틱 SEO, i18n, 로드맵 | — |
| `마케팅/GA_전략서.md` | GA4 이벤트 설계, 전자상거래 퍼널, 0원 제외 정책, 디버깅 | — |

### 콘텐츠 전략서

| 파일 | 내용 | 참조 에이전트 |
|------|------|-------------|
| `콘텐츠/VIRAL_CONTENT_MAKING_STRATEGY.md` | 감정 설계, 8대 훅, 9개 카피 패턴, 본문 3단 구조, CTA, 템플릿 7선, 워크플로우 | content-planner |
| `콘텐츠/VIRAL_GROWTH_PLAYBOOK.md` | 바이럴 삼각형, 논란 설계, 밈 생산성, 플랫폼 역학, 7개 케이스 스터디 | content-planner |
| `콘텐츠/ZALPHA_CHARACTER_GUIDE.md` | Z/Alpha 세대 캐릭터 디자인 가이드 | — |

### 개발 전략서

| 파일 | 내용 |
|------|------|
| `개발/PERFORMANCE_OPTIMIZATION.md` | 웹 성능 최적화 — 미들웨어 경량화, 캐시 4단계, 병렬화, HTTP 캐시, 재시도, ErrorBoundary |
| `개발/HARNESS_ENGINEERING.md` | Claude Code 하네스 엔지니어링 — 3중 방어, 린터/Hook 강제, 컨텍스트 관리 |
| `개발/CLAUDE_SETUP_STRATEGY.md` | .claude/ 폴더 구조 설계 — 레이어별 역할, 프로젝트 문서 작성법, DECISIONS 포맷 |
| `개발/TOKEN_OPTIMIZATION.md` | 토큰 절약 전략 — 세션 관리, .claudeignore, 문서 최적화, 서브에이전트, 모델 선택 |
| `개발/ONTOLOGY_GUIDE.md` | 온톨로지 설계 가이드 |
| `개발/SECURITY.md` | 보안 가이드 |

---

## MCP Servers

| MCP | 설명 | API Key |
|-----|------|---------|
| **Vercel** | 배포, 프로젝트 관리 | claude.ai 연동 |
| **Figma** | 디자인 to 코드 | claude.ai 연동 |
| **Notion** | 문서 읽기/쓰기 | claude.ai 연동 |
| **Supabase** | DB 관리 (plugin) | claude.ai 연동 |
| **Serena** | LSP 기반 코드 분석 (plugin) | 불필요 |
| **Playwriter** | 브라우저 자동화 (Playwright) | 불필요 |
| **Apify Actors** | 웹 크롤링/스크래핑 | Required |

---

## Configuration

### settings.json
글로벌 설정 — permissions (allow/deny), 플러그인, 기본 모드(`acceptEdits`)

### settings.local.json
기기별 로컬 설정 — MCP 서버 + API 키. **절대 git 커밋 금지.**

---

## API Key Registration

| Service | URL |
|---------|-----|
| Apify | https://console.apify.com/account/integrations |
| Supabase | https://supabase.com/dashboard/account/tokens |
| Figma | Figma App > Settings > Personal access tokens |
| Vercel/Notion/Gmail | claude.ai 연동 (Settings > Connected apps) |

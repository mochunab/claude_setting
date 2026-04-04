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
cp -r ~/claude_setting/claude/hooks ~/.claude/hooks
cp -r ~/claude_setting/claude/docs ~/.claude/docs

# 3. hooks 실행 권한
chmod +x ~/.claude/hooks/*.sh

# 4. API keys (settings.local.json에 직접 설정)
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
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\hooks $env:USERPROFILE\.claude\hooks
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\docs $env:USERPROFILE\.claude\docs
# MCP 서버 설정은 %USERPROFILE%\.claude\settings.local.json에 수동 구성
```

---

## File Structure

```
claude_setting/
├── claude/
│   ├── CLAUDE.md                      # 글로벌 개발 원칙 (모든 프로젝트 자동 적용)
│   ├── settings.json                  # 플러그인 + 훅 + 권한
│   │
│   ├── rules/                         # 글로벌 룰 (매 세션 자동 적용)
│   │   ├── security.md                #   보안 원칙
│   │   ├── performance.md             #   성능 원칙
│   │   └── testing.md                 #   테스트 원칙
│   │
│   ├── hooks/                         # 글로벌 안전 훅 + 프로젝트용 템플릿
│   │   ├── block-dangerous.sh         #   파괴적 명령 차단 (PreToolUse)
│   │   ├── protect-files.sh           #   민감 파일 보호 (PreToolUse)
│   │   └── lint-changed.sh            #   린트 자동 실행 템플릿 (프로젝트별 적용)
│   │
│   ├── agents/                        # 글로벌 에이전트 (8개)
│   │   ├── code-searcher.md
│   │   ├── deploy-checker.md
│   │   ├── edge-function-dev.md
│   │   ├── qa-tester.md
│   │   ├── ui-reviewer.md
│   │   ├── content-planner.md
│   │   ├── feature-planner.md
│   │   └── growth-strategist.md
│   │
│   ├── commands/                      # 슬래시 커맨드
│   │   └── thread.md                  #   스레드 바이럴 글 작성기
│   │
│   ├── skills/                        # 스킬 (3개 커스텀)
│   │   ├── ui-ux-pro-max/             #   UI/UX 디자인 (67 styles, 96 palettes)
│   │   ├── trend/                     #   멀티 플랫폼 트렌드 서칭
│   │   └── gemini-web-fetch/          #   WebFetch 폴백 (Gemini)
│   │
│   └── docs/                          # 사람용 레퍼런스 (Claude 자동 탐색 대상 아님)
│       ├── 개발/
│       │   ├── HOOKS_STRATEGY.md      #   Hook 전략서 + 프로젝트별 적용 가이드
│       │   ├── CLAUDE_SETUP_STRATEGY.md
│       │   ├── HARNESS_ENGINEERING.md
│       │   ├── TOKEN_OPTIMIZATION.md
│       │   ├── PERFORMANCE_OPTIMIZATION.md
│       │   ├── SECURITY.md
│       │   └── ONTOLOGY_GUIDE.md
│       ├── 비즈니스/
│       │   ├── UNIVERSAL_GROWTH_FORMULA.md
│       │   ├── AARRR_FUNNEL_STRATEGY.md
│       │   └── PM_FRAMEWORKS.md
│       ├── 마케팅/
│       │   ├── VIRAL_FEATURE_STRATEGY.md
│       │   ├── SEO_전략서.md
│       │   └── GA_전략서.md
│       └── 콘텐츠/
│           ├── VIRAL_CONTENT_MAKING_STRATEGY.md
│           ├── VIRAL_GROWTH_PLAYBOOK.md
│           └── ZALPHA_CHARACTER_GUIDE.md
└── README.md
```

---

## 레이어 구조

```
rules/          매 세션 자동 로드     Claude가 반드시 따르는 코딩 규칙
hooks/          도구 사용 시 자동 실행  안전장치 (차단/보호) + 품질 자동화 (린트)
agents/         명시적 호출            전문 작업 수행 (배포 점검, UI 리뷰, 기획)
skills/         키워드 트리거          특정 주제 감지 시 자동 활성화
commands/       /커맨드 실행           사용자가 직접 호출하는 워크플로우
docs/           사람이 직접 열람       Claude 자동 탐색 대상 아님 (에이전트가 명시 참조만)
```

---

## Hooks (안전장치)

### 글로벌 (모든 프로젝트 자동 적용)

| Hook | 이벤트 | 역할 |
|------|--------|------|
| `block-dangerous.sh` | PreToolUse: Bash | `rm -rf`, `git reset --hard`, `git push --force` (force-with-lease 허용), `DROP TABLE` 등 차단 |
| `protect-files.sh` | PreToolUse: Edit\|Write | `.env`, `.git/`, lock 파일, `.pem`, `.key`, `secrets/` 수정 차단 |

### 프로젝트별 (템플릿 제공)

| Hook | 이벤트 | 역할 |
|------|--------|------|
| `lint-changed.sh` | PostToolUse: Edit\|Write | 변경된 파일에 ESLint 자동 실행. 프로젝트에 ESLint 없으면 통과 |

프로젝트별 적용법은 `docs/개발/HOOKS_STRATEGY.md` 참조.

---

## Rules (자동 적용 — 3개)

| Rule | 역할 |
|------|------|
| `security.md` | 시크릿 관리, 입력검증, 에러처리, CORS, 인시던트 대응 |
| `performance.md` | 미들웨어 경량화, 캐시 레이어, 병렬화, staleTimes, 로딩 전략 |
| `testing.md` | 테스트 작성 기준, 단위/통합/E2E, mock 정책, 테스트 구조 |

---

## Agents (8개)

### 개발 에이전트

| Agent | 용도 | 트리거 |
|-------|------|--------|
| `code-searcher` | 코드베이스 탐색, 영향도 분석 | "찾아줘", "어디서", "영향도" |
| `deploy-checker` | 배포 전 빌드/보안/환경변수 점검 | "배포 전 점검", "프로덕션 체크" |
| `edge-function-dev` | Supabase Edge Function 개발/디버깅 | Edge Function 관련 작업 |
| `qa-tester` | Playwright MCP 기반 브라우저 QA 테스트 | "QA", "테스트", "점검" |
| `ui-reviewer` | UI/디자인 리뷰 (스킬 자동 라우팅) | "UI 검사", "디자인 체크" |

### 비즈니스 에이전트

| Agent | 용도 | 참조 문서 |
|-------|------|----------|
| `content-planner` | 바이럴 콘텐츠 기획 — 감정 설계, 훅 카피, CTA | `docs/콘텐츠/` |
| `feature-planner` | 바이럴 기능/제품 설계 — 심리 트리거, 공유 루프 | `docs/마케팅/`, `docs/비즈니스/` |
| `growth-strategist` | 사업 성장 전략 — 본능 분석, AARRR 퍼널 | `docs/비즈니스/` |

---

## Commands (슬래시 커맨드)

| 커맨드 | 용도 |
|--------|------|
| `/thread` | 스레드 바이럴 글 자동 생성 (본글 + 댓글 구조) |

---

## Plugins (5개)

| Plugin | 역할 |
|--------|------|
| `vercel` | 배포, CLI, Functions, AI SDK, shadcn, React best practices 등 |
| `supabase` | DB 관리, Edge Functions, 마이그레이션 |
| `feature-dev` | 7단계 기능 개발 워크플로우 (탐색→설계→구현→리뷰) |
| `pr-review-toolkit` | PR 코드 리뷰 (6개 전문 에이전트) |
| `frontend-design` | 프리미엄 프론트엔드 생성 |

---

## docs/ (사람용 레퍼런스)

Claude가 자동 탐색하지 않는 문서. 에이전트가 명시적 경로로 참조하거나, 사람이 직접 열람.

| 카테고리 | 파일 | 내용 |
|----------|------|------|
| 개발 | `HOOKS_STRATEGY.md` | Hook 전략서 + 프로젝트별 적용 가이드 |
| 개발 | `CLAUDE_SETUP_STRATEGY.md` | .claude/ 폴더 구조 설계 |
| 개발 | `HARNESS_ENGINEERING.md` | 하네스 엔지니어링 방법론 |
| 개발 | `TOKEN_OPTIMIZATION.md` | 토큰 절약 전략 |
| 개발 | `PERFORMANCE_OPTIMIZATION.md` | 성능 최적화 확장판 (rules/ 보충) |
| 개발 | `SECURITY.md` | 보안 가이드 확장판 (rules/ 보충) |
| 개발 | `ONTOLOGY_GUIDE.md` | 온톨로지 설계 가이드 |
| 비즈니스 | `UNIVERSAL_GROWTH_FORMULA.md` | 5단계 성장 엔진 (본능→훅→확산→전환→잠금) |
| 비즈니스 | `AARRR_FUNNEL_STRATEGY.md` | AARRR 퍼널 설계 + 단계별 지표 |
| 비즈니스 | `PM_FRAMEWORKS.md` | PM 프레임워크 8종 |
| 마케팅 | `VIRAL_FEATURE_STRATEGY.md` | 바이럴 기능 설계 + 26개 케이스 스터디 |
| 마케팅 | `SEO_전략서.md` | SEO 체크리스트 + 기술적/콘텐츠 SEO |
| 마케팅 | `GA_전략서.md` | GA4 이벤트 설계 + 퍼널 분석 |
| 콘텐츠 | `VIRAL_CONTENT_MAKING_STRATEGY.md` | 감정 설계, 8대 훅, 9개 카피 패턴 |
| 콘텐츠 | `VIRAL_GROWTH_PLAYBOOK.md` | 바이럴 삼각형, 논란 설계, 밈 생산성 |
| 콘텐츠 | `ZALPHA_CHARACTER_GUIDE.md` | Z/Alpha 세대 캐릭터 디자인 가이드 |

---

## Configuration

### settings.json
글로벌 설정 — hooks, 플러그인, 기본 모드

### settings.local.json
기기별 로컬 설정 — MCP 서버 + API 키. **절대 git 커밋 금지.**

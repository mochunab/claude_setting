# Claude Setting

Claude Code 환경 설정 파일 저장소

## Quick Start

### macOS / Linux (Bash)

```bash
# 1. Clone
git clone https://github.com/mochunab/claude_setting.git ~/claude_setting

# 2. 설정 파일 복사
cp ~/claude_setting/claude/settings.json ~/.claude/settings.json
cp -r ~/claude_setting/claude/agents ~/.claude/agents
cp -r ~/claude_setting/claude/rules ~/.claude/rules
cp -r ~/claude_setting/claude/skills ~/.claude/skills
cp -r ~/claude_setting/claude/commands ~/.claude/commands
cp -r ~/claude_setting/claude/knowledge ~/.claude/knowledge

# 3. API keys
export FIRECRAWL_API_KEY="your-firecrawl-api-key"
export SUPABASE_ACCESS_TOKEN="your-supabase-token"

# 4. MCP setup
chmod +x ~/claude_setting/claude/setup-mcp.sh
~/claude_setting/claude/setup-mcp.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/mochunab/claude_setting.git $env:USERPROFILE\claude_setting
Copy-Item $env:USERPROFILE\claude_setting\claude\settings.json $env:USERPROFILE\.claude\settings.json
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\agents $env:USERPROFILE\.claude\agents
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\rules $env:USERPROFILE\.claude\rules
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\skills $env:USERPROFILE\.claude\skills
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\commands $env:USERPROFILE\.claude\commands
Copy-Item -Recurse $env:USERPROFILE\claude_setting\claude\knowledge $env:USERPROFILE\.claude\knowledge
$env:FIRECRAWL_API_KEY = "your-firecrawl-api-key"
$env:SUPABASE_ACCESS_TOKEN = "your-supabase-token"
& $env:USERPROFILE\claude_setting\claude\setup-mcp.ps1
```

---

## File Structure

```
claude_setting/
├── claude/
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
│   │   └── security.md
│   ├── commands/                      # 슬래시 커맨드
│   │   ├── property.md
│   │   └── thread.md
│   ├── skills/                        # 스킬 (26개)
│   │   ├── nadaunse-taste/
│   │   ├── supanova-design-skill/
│   │   ├── trend/
│   │   ├── ui-ux-pro-max/
│   │   └── vercel-react-best-practices/
│   ├── knowledge/                     # 지식 베이스
│   │   ├── 마케팅_용어.txt
│   │   ├── 서비스_기획.txt
│   │   └── 행동경제학.txt
│   ├── settings.json
│   ├── settings.local.json.example
│   ├── setup-mcp.sh
│   └── setup-mcp.ps1
└── README.md
```

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
| **feature-planner** | 바이럴 기능/제품 설계 — 심리 트리거, 공유 루프 | "기능 기획", "바이럴 기능" |
| **growth-strategist** | 사업 성장 전략 — 본능 분석, 전환/잠금 설계 | "사업 전략", "성장 설계" |

### ui-reviewer 스킬 라우팅

ui-reviewer는 요청 유형에 따라 보유 디자인 스킬을 자동 선택하여 리뷰합니다:

| 요청 유형 | 적용 스킬 |
|-----------|-----------|
| 랜딩페이지 신규 | supanova-design-engine |
| 리디자인 | supanova-redesign-engine |
| 프리미엄 미학 | supanova-premium-aesthetic |
| 완전 출력 검증 | supanova-full-output |
| 일반 UI/UX | ui-ux-pro-max (기본) |
| React/Next.js | frontend-patterns |

---

## Rules (자동 적용)

| Rule | 역할 |
|------|------|
| **security.md** | 보안 기본 원칙 — 시크릿 관리, 입력검증, 에러처리, CORS, 인시던트 대응 |

> 모든 코딩 작업 시 자동으로 로드됩니다. 프로젝트별 추가 Rules는 `프로젝트/.claude/rules/`에 배치.

---

## Skills

### 디자인

| Skill | 용도 |
|-------|------|
| **ui-ux-pro-max** | UI/UX 디자인 인텔리전스 (67 styles, 96 palettes, 57 font pairings, 13 stacks) |
| **supanova-design-skill** | 프리미엄 랜딩페이지 생성/리디자인/미학/출력 강제 (4개 서브스킬) |
| **nadaunse-taste** | 나다운세 프론트엔드 디자인 품질 (프로젝트 전용) |
| **vercel-react-best-practices** | React/Next.js 성능 최적화 (Vercel Engineering 기반) |

### 콘텐츠/마케팅

| Skill | 용도 |
|-------|------|
| **trend** | 멀티 플랫폼 트렌드 서칭 (X, 인스타, 스레드, 틱톡, 유튜브, 레딧) |

---

## Commands (슬래시 커맨드)

| 커맨드 | 용도 |
|--------|------|
| `/thread` | 스레드 바이럴 글 자동 생성 (본글 + 댓글 구조) |
| `/property` | 주택 청약 분석 |

---

## Knowledge Base

| 파일 | 내용 |
|------|------|
| `마케팅_용어.txt` | AARRR, GTM, PMF, 브랜딩 vs 마케팅, 플랫폼 BM |
| `서비스_기획.txt` | 기획 순서, OMTM, KPI, 화면 설계, 애자일 |
| `행동경제학.txt` | 피크엔드 법칙, 앵커링, 선택의 역설, 손실회피 |

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
글로벌 설정 — bash 권한, 플러그인 목록, 기본 모드/모델

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

# Dotfiles

Claude Code 환경 설정 파일 저장소

## Quick Start

### Windows (PowerShell)

```powershell
# 1. Clone repository
git clone https://github.com/stargiosoft/dotfiles.git $env:USERPROFILE\dotfiles

# 2. Claude 설정 파일 복사
Copy-Item $env:USERPROFILE\dotfiles\claude\settings.json $env:USERPROFILE\.claude\settings.json
Copy-Item -Recurse $env:USERPROFILE\dotfiles\claude\commands $env:USERPROFILE\.claude\commands
Copy-Item -Recurse $env:USERPROFILE\dotfiles\claude\knowledge $env:USERPROFILE\.claude\knowledge

# 3. Set API keys (required MCP servers)
$env:FIRECRAWL_API_KEY = "your-firecrawl-api-key"
$env:SUPABASE_ACCESS_TOKEN = "your-supabase-token"

# Optional
# $env:FIGMA_API_KEY = "your-figma-api-key"

# 4. Run setup script
& $env:USERPROFILE\dotfiles\claude\setup-mcp.ps1
```

### macOS / Linux (Bash)

```bash
# 1. Clone repository
git clone https://github.com/stargiosoft/dotfiles.git ~/dotfiles

# 2. Claude 설정 파일 복사
cp ~/dotfiles/claude/settings.json ~/.claude/settings.json
cp -r ~/dotfiles/claude/commands ~/.claude/commands
cp -r ~/dotfiles/claude/knowledge ~/.claude/knowledge

# 3. Set API keys (required MCP servers)
export FIRECRAWL_API_KEY="your-firecrawl-api-key"
export SUPABASE_ACCESS_TOKEN="your-supabase-token"

# Optional
# export FIGMA_API_KEY="your-figma-api-key"

# 4. Run setup script
chmod +x ~/dotfiles/claude/setup-mcp.sh
~/dotfiles/claude/setup-mcp.sh
```

**Note**:
- **Required**: Firecrawl, Supabase (API keys needed)
- **Always installed**: Playwright (no API key needed)
- **Optional**: Figma (skip if API key not set)

---

## File Structure

```
dotfiles/
├── claude/
│   ├── agents/                       # 글로벌 에이전트 (모든 프로젝트)
│   │   ├── content-planner.md
│   │   ├── feature-planner.md
│   │   ├── growth-strategist.md
│   │   └── nadaunse/                 # 나다운세 전용 에이전트
│   │       ├── qa-tester.md
│   │       ├── code-searcher.md
│   │       ├── edge-function-dev.md
│   │       ├── ui-reviewer.md
│   │       └── deploy-checker.md
│   ├── commands/                     # 커스텀 슬래시 커맨드
│   │   ├── property.md
│   │   └── thread.md
│   ├── skills/                       # 커스텀 스킬
│   │   ├── nadaunse-taste/
│   │   ├── trend/
│   │   ├── ui-ux-pro-max/
│   │   └── vercel-react-best-practices/
│   ├── knowledge/                    # AI 지식 베이스
│   │   ├── 마케팅_용어.txt
│   │   ├── 서비스_기획.txt
│   │   └── 행동경제학.txt
│   ├── setup-mcp.sh                  # Unix/Mac setup script
│   ├── setup-mcp.ps1                 # Windows setup script
│   ├── settings.json                 # 글로벌 설정 (plugins, permissions)
│   └── settings.local.json.example  # 로컬 설정 템플릿 (API keys 포함)
└── README.md
```

---

## Custom Commands (Slash Commands)

`~/.claude/commands/` 에 `.md` 파일을 두면 Claude Code에서 `/파일명` 으로 실행할 수 있어.

### /thread — 스레드 바이럴 글 작성기

```
/thread
/thread 비즈니스 모델 주제로 써줘
/thread 오늘 온보딩 이탈률 보고 충격받음
```

IT 기획자 페르소나로 스레드(Threads) 바이럴 글을 자동 생성.
- knowledge 파일에서 반직관적 인사이트 자동 추출
- 본글(5줄) + 댓글(2~5개) 구조로 출력
- 후킹 전략, 리듬, 줄바꿈까지 설계

---

## Knowledge Base

`~/.claude/knowledge/` 에 `.txt` 파일을 두면 커스텀 커맨드에서 참조할 수 있어.

| 파일 | 내용 |
|------|------|
| `마케팅_용어.txt` | AARRR, GTM, PMF, 브랜딩 vs 마케팅, 플랫폼 BM 등 |
| `서비스_기획.txt` | 기획 순서, OMTM, KPI, 화면 설계, 애자일 등 |
| `행동경제학.txt` | 피크엔드 법칙, 앵커링, 선택의 역설, 손실회피 등 |

---

## Installed Components

### MCP Servers

**글로벌 (모든 프로젝트)**:

| MCP | Description | API Key | Status |
|-----|-------------|---------|--------|
| **Vercel** | 배포, 프로젝트 관리 | claude.ai 연동 | ✅ |
| **Figma** | 디자인 to 코드 | claude.ai 연동 | ✅ |
| **Notion** | 문서 읽기/쓰기 | claude.ai 연동 | ✅ |
| **Supabase** | DB 관리 (plugin) | claude.ai 연동 | ✅ |
| **Serena** | LSP 기반 코드 분석 (plugin) | 불필요 | ✅ |
| **Playwriter** | 브라우저 자동화 (Playwright 래퍼) | 불필요 | ✅ |
| **Apify Actors** | 웹 크롤링/스크래핑 (인스타, 트렌드 등) | **Required** | ✅ |
| Gmail | 이메일 | claude.ai 연동 | ⚠️ 인증 필요 |
| Google Calendar | 캘린더 | claude.ai 연동 | ⚠️ 인증 필요 |
| Zapier | 자동화 워크플로우 | claude.ai 연동 | ⚠️ 인증 필요 |
| Canva | 디자인 | claude.ai 연동 | ⚠️ 인증 필요 |

**프로젝트별 (나다운세)**:

| MCP | Description | 설정 위치 |
|-----|-------------|----------|
| Playwright | E2E 브라우저 테스트 | 프로젝트 `.claude.json` |
| Supabase | DB 직접 연결 (access token) | 프로젝트 `.claude.json` |

### Plugins

| Plugin | Description | Status |
|--------|-------------|--------|
| **feature-dev** | Feature development guide | ✅ |
| **supabase** | Supabase DB management | ✅ |
| **code-review** | Code review | ✅ |
| **pr-review-toolkit** | PR review tools | ✅ |
| **frontend-design** | Frontend design | ✅ |
| **typescript-lsp** | TypeScript LSP | ✅ |
| **serena** | LSP-based semantic code analysis | ✅ |
| claude-mem | Persistent memory system | ⚠️ Optional |

---

## API Key Registration

| Service | URL |
|---------|-----|
| Apify | https://console.apify.com/account/integrations |
| Supabase | https://supabase.com/dashboard/account/tokens |
| Figma | Figma App > Settings > Personal access tokens |
| Vercel/Notion/Gmail 등 | claude.ai 연동 (Settings > Connected apps) |

---

## Configuration Files

### settings.json

글로벌 설정 파일. `~/.claude/settings.json` 에 위치.
- 허용/차단 bash 명령어 권한
- 활성화된 플러그인 목록
- 기본 모드, 모델 설정

### settings.local.json

기기별 로컬 설정. `settings.local.json.example` 을 복사해서 사용.
- MCP 서버 설정 (API 키 포함)
- 기기별 추가 bash 권한

**주의:** API 키가 포함되므로 절대 git에 커밋하지 말 것.

---

## Agents

### 세일즈 에이전트 (Global — 모든 프로젝트)

| Agent | Description | Trigger Keywords |
|-------|-------------|-----------------|
| **content-planner** | 바이럴 콘텐츠(글/영상) 기획 — 감정 설계, 훅 카피, 본문 3단 구조, CTA | "콘텐츠 기획", "카피 써줘", "훅 만들어" |
| **feature-planner** | 바이럴 기능/제품 설계 — 심리 트리거, 공유 루프, 케이스 스터디 매칭 | "기능 기획", "바이럴 기능", "공유 루프" |
| **growth-strategist** | 사업 성장 전략 — 7대 본능 분석, 5단계 성장 엔진, 전환/잠금 설계 | "사업 전략", "성장 설계", "본능 분석" |

### 개발 에이전트 (나다운세 전용)

> `agents/nadaunse/` 폴더의 파일을 프로젝트의 `.claude/agents/`에 복사해서 사용

| Agent | Description | Trigger Keywords |
|-------|-------------|-----------------|
| **qa-tester** | Playwright 기반 실제 브라우저 QA 테스트, E2E 시나리오 점검 | "QA", "테스트", "점검" |
| **code-searcher** | 72개 컴포넌트, 46개 EF, 55개 페이지 코드 탐색 및 영향도 분석 | "찾아줘", "어디서", "영향도" |
| **edge-function-dev** | Edge Function 생성/수정/디버깅, Deno·CORS·JWT 규칙 자동 적용 | EF 관련 모든 작업 |
| **ui-reviewer** | Tailwind v4 규칙, 디자인 시스템 준수 검사, iOS Safari 호환성 리뷰 | "UI 검사", "스타일 리뷰" |
| **deploy-checker** | 배포 전 빌드 오류, 보안 취약점, 환경변수 누락, DEV 노출 점검 | "배포 전 점검" |

---

## Skills

| Skill | Description |
|-------|-------------|
| **nadaunse-taste** | 나다운세 프론트엔드 디자인 품질 스킬 |
| **trend** | 멀티 플랫폼 트렌드 서칭 |
| **ui-ux-pro-max** | UI/UX 디자인 인텔리전스 (67 styles, 96 palettes) |
| **vercel-react-best-practices** | React/Next.js 성능 최적화 가이드라인 |

---

## Figma MCP 설정 주의사항

Figma MCP는 CLI 설치 불가. `~/.claude.json` 을 직접 수정해야 해.

```json
{
  "mcpServers": {
    "figma": {
      "type": "http",
      "url": "https://mcp.figma.com/mcp",
      "headers": {
        "X-Figma-Token": "YOUR_FIGMA_API_KEY_HERE"
      }
    }
  }
}
```

> ❌ `@anthropic/mcp-server-figma` (stdio/SSE) 는 deprecated. HTTP transport 사용할 것.

---

## Troubleshooting

### MCP 연결 확인

```bash
claude mcp list
```

Claude Code 내에서 `/mcp` 명령으로도 확인 가능.

### claude-mem Worker 실행

**Windows:**
```powershell
$env:USERPROFILE\.bun\bin\bun.exe (Get-ChildItem $env:USERPROFILE\.claude\plugins\cache\thedotmack\claude-mem\*\scripts\worker-cli.js).FullName start
```

**macOS / Linux:**
```bash
bun ~/.claude/plugins/cache/thedotmack/claude-mem/*/scripts/worker-cli.js start
```

Web viewer: http://localhost:37777

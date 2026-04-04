# Claude Code Hooks 전략서

> 프로젝트 세팅 시 이 문서를 참고하여 hooks를 구성한다.
> 글로벌 hooks(~/.claude/)는 안전장치, 프로젝트 hooks(project/.claude/)는 품질 자동화.
> 최종 업데이트: 2026-04-04

---

## 1. 구조 원칙

```
~/.claude/settings.json          ← 글로벌 (모든 프로젝트 공통)
├── PreToolUse: block-dangerous  ← 파괴적 명령 차단
└── PreToolUse: protect-files    ← 민감 파일 보호

project/.claude/settings.json    ← 프로젝트별 (린터/포맷터에 따라 다름)
└── PostToolUse: lint-changed    ← Edit/Write 후 자동 린트
```

### 글로벌 vs 프로젝트별 판단 기준

| 질문 | 글로벌 | 프로젝트별 |
|------|--------|-----------|
| 모든 프로젝트에 동일? | O (안전장치) | X |
| 린터/포맷터에 의존? | X | O (ESLint, Biome 등) |
| 없으면 위험? | O → 글로벌 | X → 프로젝트별 |

---

## 2. 글로벌 Hooks (현재 적용 중)

### PreToolUse — 위험 명령 차단 (`block-dangerous.sh`)

```json
{
  "matcher": "Bash",
  "hooks": [{
    "type": "command",
    "command": "~/.claude/hooks/block-dangerous.sh"
  }]
}
```

**차단 패턴:**
- `rm -rf`, `git reset --hard`, `git push --force` (force-with-lease는 허용), `git clean -f`
- `DROP TABLE`, `DROP DATABASE`, `TRUNCATE`
- `curl | sh`, `wget | bash` (원격 스크립트 실행)

**동작:** exit 2 → Claude에게 "더 안전한 대안을 제안하라"고 메시지 반환.

### PreToolUse — 민감 파일 보호 (`protect-files.sh`)

```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "~/.claude/hooks/protect-files.sh"
  }]
}
```

**보호 대상:** `.env`, `.git/`, lock 파일, `.pem`, `.key`, `secrets/`

**동작:** exit 2 → Claude에게 "왜 이 파일을 수정해야 하는지 설명하라"고 요구.

---

## 3. 프로젝트별 Hooks (신규 프로젝트 세팅 시 적용)

### PostToolUse — 린트 자동 실행

프로젝트의 린터에 따라 아래 중 하나를 선택하여 `project/.claude/settings.json`에 추가.

#### ESLint 프로젝트

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/lint-changed.sh"
      }]
    }]
  }
}
```

글로벌 `~/.claude/hooks/lint-changed.sh`가 이미 ESLint 자동 감지하므로 스크립트 추가 불필요.

#### Biome 프로젝트

`project/.claude/hooks/lint-biome.sh` 생성:

```bash
#!/usr/bin/env bash
set -euo pipefail

file=$(jq -r '.tool_input.file_path // .tool_input.path // ""')

case "$file" in
  *.ts|*.tsx|*.js|*.jsx|*.json) ;;
  *) exit 0 ;;
esac

dir=$(dirname "$file")
project_root=""
while [ "$dir" != "/" ]; do
  if [ -f "$dir/biome.json" ] || [ -f "$dir/biome.jsonc" ]; then
    project_root="$dir"
    break
  fi
  dir=$(dirname "$dir")
done

[ -z "$project_root" ] && exit 0

biome_bin="$project_root/node_modules/.bin/biome"
[ ! -x "$biome_bin" ] && exit 0

cd "$project_root"
"$biome_bin" check --skip-errors "$file" 2>&1 || true
exit 0
```

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/lint-biome.sh"
      }]
    }]
  }
}
```

---

## 4. 선택적 Hooks (필요 시 추가)

### PostToolUse — 타입 체크 (대규모 리팩토링 시)

```bash
#!/usr/bin/env bash
set -euo pipefail

file=$(jq -r '.tool_input.file_path // .tool_input.path // ""')

case "$file" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

dir=$(dirname "$file")
project_root=""
while [ "$dir" != "/" ]; do
  if [ -f "$dir/tsconfig.json" ]; then
    project_root="$dir"
    break
  fi
  dir=$(dirname "$dir")
done

[ -z "$project_root" ] && exit 0

cd "$project_root"
npx tsc --noEmit --pretty 2>&1 | head -20 || true
exit 0
```

> 주의: tsc는 전체 프로젝트를 체크하므로 느림. 대규모 타입 변경 작업에서만 일시적으로 사용.

### UserPromptSubmit — 컨텍스트 자동 주입

특정 키워드 입력 시 관련 문서를 자동으로 Claude 컨텍스트에 추가.

```bash
#!/usr/bin/env bash
set -euo pipefail

prompt=$(jq -r '.user_prompt // ""')

if echo "$prompt" | grep -qiE "배포|deploy|production"; then
  echo "배포 관련 작업입니다. deploy-checker 에이전트 사용을 권장합니다."
fi
exit 0
```

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/context-inject.sh"
      }]
    }]
  }
}
```

---

## 5. Hook 이벤트 레퍼런스

| 이벤트 | 시점 | 주 용도 |
|--------|------|---------|
| `PreToolUse` | 도구 실행 **전** | 위험 행동 차단, 파일 보호 |
| `PostToolUse` | 도구 실행 **후** | 린트, 포맷, 타입 체크 |
| `UserPromptSubmit` | 사용자 입력 **후** | 컨텍스트 주입, 키워드 라우팅 |
| `Notification` | 알림 발생 시 | 외부 연동 (Slack 등) |
| `Stop` | 턴 종료 시 | 정리 작업, 로깅 |

### exit 코드 규칙

| 코드 | 의미 |
|------|------|
| `exit 0` | 통과 — 정상 진행 |
| `exit 2` | 차단 — Claude에게 stderr 메시지 전달, 도구 실행 중단 |
| 그 외 | 오류 — 훅 자체 실패로 처리 |

---

## 6. 신규 프로젝트 세팅 체크리스트

프로젝트 초기 세팅 시 아래를 확인:

1. **린터 확인** — ESLint? Biome? 없음?
2. **해당 린터에 맞는 PostToolUse 훅** → `project/.claude/settings.json`에 추가
3. **글로벌 hooks 동작 확인** — block-dangerous, protect-files는 자동 적용됨
4. **(선택) 프로젝트 전용 보호 파일** 있으면 protect-files 확장 또는 프로젝트별 훅 추가

```
# 요청 예시
"이 프로젝트에 .claude/settings.json 만들어줘. 
린터는 ESLint야. PostToolUse로 lint-changed.sh 연결해줘."
```

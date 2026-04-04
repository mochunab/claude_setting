#!/usr/bin/env bash
set -euo pipefail

# PostToolUse: Edit/Write 후 변경된 파일에 린트 실행
# 프로젝트에 ESLint가 없으면 조용히 통과

file=$(jq -r '.tool_input.file_path // .tool_input.path // ""')

# 대상 확장자 필터
case "$file" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

# 프로젝트 루트 탐색 (package.json 기준)
dir=$(dirname "$file")
project_root=""
while [ "$dir" != "/" ]; do
  if [ -f "$dir/package.json" ]; then
    project_root="$dir"
    break
  fi
  dir=$(dirname "$dir")
done

[ -z "$project_root" ] && exit 0

# ESLint 존재 확인
eslint_bin="$project_root/node_modules/.bin/eslint"
[ ! -x "$eslint_bin" ] && exit 0

# 린트 실행 (경고만 출력, 블로킹하지 않음)
cd "$project_root"
"$eslint_bin" --no-error-on-unmatched-pattern --max-warnings=-1 "$file" 2>&1 || true
exit 0

#!/bin/bash
# PostToolUse hook: 파일 수정 후 자동 린트

set -euo pipefail

# stdin에서 JSON 입력 읽기
INPUT=$(cat)

# 파일 경로 추출
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 파일 경로가 없으면 종료
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# 파일이 존재하지 않으면 종료 (삭제된 경우)
if [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# just lint-file 실행
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if command -v just &> /dev/null && [[ -f "justfile" ]]; then
    just lint-file "$FILE_PATH" 2>&1 || true
fi

exit 0

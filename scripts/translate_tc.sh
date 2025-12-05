#!/bin/bash

# Automated Translation: English -> Traditional Chinese (繁體)
# Uses same backends as translate_sc.sh (github/openai/doubao/test)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
EN_DIR="${PROJECT_DIR}/cyberplaza_whitepaper/mainmatter"
# Allow overriding output directory via environment variable (safe preview runs)
TC_DIR="${TC_DIR:-${PROJECT_DIR}/cyberplaza_whitepaper/mainmatter_tc}"

API_TYPE="${API_TYPE:-doubao}"
MODEL="${MODEL:-doubao-seed-code-preview-latest}"

echo -e "${BLUE}╔════════════════════════════════════════╗"
echo "║   Automated Translation → 繁體中文     ║"
echo -e "╚════════════════════════════════════════╝${NC}"
echo ""

# Basic checks
if [ ! -d "$EN_DIR" ]; then
  echo -e "${RED}Error: Source directory not found: $EN_DIR${NC}"
  exit 1
fi
mkdir -p "$TC_DIR"

# Determine files (optional pattern arg)
if [ $# -gt 0 ]; then
  pattern="$1"
  if [[ -f "$pattern" ]]; then
    files=("$pattern")
  else
    files=($(ls "$EN_DIR"/$pattern 2>/dev/null | sort))
  fi
else
  files=($(ls "$EN_DIR"/*.tex 2>/dev/null | sort))
fi

total=${#files[@]}
if [ $total -eq 0 ]; then
  echo -e "${RED}No files to translate (pattern or EN_DIR empty)${NC}"
  exit 1
fi

echo -e "${YELLOW}Found $total files to translate → mainmatter_tc/${NC}"

# helper: translate via doubao (chat/completions messages format)
translate_with_doubao_tc() {
  local content="$1"
  local prompt="請將下面的 LaTeX 文件從英文翻譯為繁體中文（台灣/香港常用用詞）。\n\n注意：\n1) 保留所有 LaTeX 命令、標籤、公式不變（例如 \section{}, \cite{}, \ref{} 等）。\n2) 保持段落結構與格式。\n3) 在繁體中文翻譯中使用繁體字詞、保留專有名詞原文或使用常用譯名。\n4) 不要額外加上說明或注釋；僅輸出完整的繁體中文 LaTeX 原文內容。\n\n英文內容:\n$content"

  if [ -z "$DOUBAO_URL" ] || [ -z "$DOUBAO_KEY" ]; then
    echo "" >&2
    echo -e "${YELLOW}DOUBAO_URL/DOUBAO_KEY 未設定，跳過 Doubao 請求${NC}" >&2
    return 1
  fi

  endpoint="$DOUBAO_URL"
  if [[ "$endpoint" != *"chat"* ]]; then
    endpoint="${endpoint%/}"
    endpoint="$endpoint/chat/completions"
  fi

  response=$(curl -s -X POST "$endpoint" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DOUBAO_KEY" \
    -d "{\"model\": \"$MODEL\", \"messages\": [{\"role\": \"user\", \"content\": $(echo "$prompt" | jq -Rs .)}], \"temperature\": 0.3}")

  echo "$response" | jq -r '.choices[0].message.content // .choices[0].text // .result // .output[0].content // .data[0].content // .response // empty'
}

# fallback: test translator
translate_test_tc(){
  echo "%% TEST TRANSLATION (繁體) - placeholder"$'\n'
  echo "$1"
}

# require jq
if ! command -v jq &> /dev/null; then
  echo -e "${RED}Error: jq is required${NC}"
  echo "Install: brew install jq"
  exit 1
fi

success=0
failed=0

for ((i=0;i<total;i++)); do
  en_file="${files[$i]}"
  filename=$(basename "$en_file")
  tc_file="$TC_DIR/$filename"
  echo -e "${BLUE}[$((i+1))/$total]${NC} $filename → mainmatter_tc/$filename"

  en_content=$(cat "$en_file")

  if [ "$API_TYPE" = "doubao" ]; then
    translation=$(translate_with_doubao_tc "$en_content")
  elif [ "$API_TYPE" = "test" ]; then
    translation=$(translate_test_tc "$en_content")
  else
    # fallback to translate_with_doubao_tc (or extend later)
    translation=$(translate_with_doubao_tc "$en_content")
  fi

  if [ -n "$translation" ] && [ "$translation" != "null" ]; then
    echo "$translation" > "$tc_file"
    echo -e "  ${GREEN}✓ Saved${NC}"
    ((success++))
  else
    echo -e "  ${RED}✗ Failed${NC}"
    ((failed++))
  fi
  sleep 1
  echo ""
done

echo -e "${BLUE}===== Done =====${NC}"
echo -e "${GREEN}Success: $success${NC}  ${RED}Failed: $failed${NC}"

if [ $success -gt 0 ]; then
  echo "接下來建議執行： ./scripts/compile_tc.sh 以驗證繁體中文能否編譯通過。"
fi

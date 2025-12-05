#!/bin/bash

# Automated Translation: English to Simplified Chinese
# Using GitHub Copilot API (via GitHub Models)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
EN_DIR="${PROJECT_DIR}/cyberplaza_whitepaper/mainmatter"
# Allow overriding target directory via environment (useful for CI preview/dry-run)
SC_DIR="${SC_DIR:-${PROJECT_DIR}/cyberplaza_whitepaper/mainmatter_sc}"

# API Configuration
# Use GitHub Models (Copilot backend) or OpenAI
API_TYPE="${API_TYPE:-github}"  # github or openai
GITHUB_TOKEN="${GITHUB_TOKEN}"
OPENAI_API_KEY="${OPENAI_API_KEY}"
MODEL="${MODEL:-gpt-4o}"

echo -e "${BLUE}╔════════════════════════════════════════╗"
echo "║   Automated Translation Workflow      ║"
echo -e "╚════════════════════════════════════════╝${NC}"
echo ""

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        cat <<'USAGE'
Usage: translate_sc.sh [pattern]

By default translates all files found under cyberplaza_whitepaper/mainmatter/*.tex
You can pass a filename or glob pattern relative to that directory, e.g.

    # Test one file (dry-run):
    API_TYPE=test ./scripts/translate_sc.sh chapter-1.tex

    # Use Doubao-seed-code (example):
    export API_TYPE=doubao
    export DOUBAO_URL="https://your-doubao-endpoint/v1/chat/completions"
    export DOUBAO_KEY="your-key"
    ./scripts/translate_sc.sh

Backends supported: github, openai, doubao, test
Set API_TYPE to choose a backend. For github the script attempts to use 'gh' CLI token automatically.
USAGE
        exit 0
fi

# Check directories
if [ ! -d "$EN_DIR" ]; then
    echo -e "${RED}Error: Source directory not found: $EN_DIR${NC}"
    exit 1
fi

if [ ! -d "$SC_DIR" ]; then
    mkdir -p "$SC_DIR"
fi

# Check API configuration
if [ "$API_TYPE" = "github" ]; then
    echo -e "${CYAN}Using GitHub Models API (Copilot backend)${NC}"
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${YELLOW}GITHUB_TOKEN not set, attempting to use gh CLI...${NC}"
        if command -v gh &> /dev/null; then
            GITHUB_TOKEN=$(gh auth token 2>/dev/null)
            if [ -z "$GITHUB_TOKEN" ]; then
                echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
                echo ""
                echo "Authenticate with GitHub:"
                echo "  gh auth login"
                echo ""
                echo "Or set token manually:"
                echo "  export GITHUB_TOKEN=ghp_your_token"
                echo ""
                echo "Or use OpenAI instead:"
                echo "  export API_TYPE=openai"
                echo "  export OPENAI_API_KEY=sk-your-key"
                exit 1
            fi
        else
            echo -e "${RED}Error: GitHub CLI not found${NC}"
            echo ""
            echo "Install GitHub CLI:"
            echo "  brew install gh"
            echo "  gh auth login"
            exit 1
        fi
    fi
    echo -e "${GREEN}✓ GitHub authenticated (model: $MODEL)${NC}"
elif [ "$API_TYPE" = "doubao" ]; then
    echo -e "${CYAN}Using Doubao / domestic model endpoint${NC}"
    if [ -z "$DOUBAO_URL" ] || [ -z "$DOUBAO_KEY" ]; then
        echo -e "${RED}Error: DOUBAO_URL or DOUBAO_KEY not set${NC}"
        echo ""
        echo "Set your endpoint and key e.g.:"
        echo "  export API_TYPE=doubao"
        echo "  export DOUBAO_URL=https://your-doubao-endpoint/v1/chat/completions"
        echo "  export DOUBAO_KEY=your-api-key"
        exit 1
    fi
    echo -e "${GREEN}✓ Doubao endpoint ready: $DOUBAO_URL${NC}"
elif [ "$API_TYPE" = "test" ]; then
    echo -e "${CYAN}Using TEST mode - no external API will be called${NC}"
    echo -e "${YELLOW}Tip: use this to verify processing and file output${NC}"
    # no credential checks
    :
else
    echo -e "${CYAN}Using OpenAI API${NC}"
    if [ -z "$OPENAI_API_KEY" ]; then
        echo -e "${RED}Error: OPENAI_API_KEY not set${NC}"
        echo ""
        echo "Set your API key:"
        echo "  export OPENAI_API_KEY=sk-your-key"
        exit 1
    fi
    echo -e "${GREEN}✓ OpenAI API key found (model: $MODEL)${NC}"
fi
echo ""

# Get files (optionally accept a file pattern or single filename)
if [ $# -gt 0 ]; then
    # User passed a filename or pattern (relative to EN_DIR)
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
    echo -e "${RED}Error: No .tex files found in $EN_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}Found $total files to translate${NC}"
echo ""

# Translation function using GitHub Models
translate_with_github() {
    local content="$1"
    local prompt="将下面的 LaTeX 文档从英文翻译成简体中文。

【重要规则】
1. 保持所有 LaTeX 命令不变（\\section{}、\\cite{}、\\ref{}、\\label{} 等）
2. 只翻译文本内容，不翻译命令和参数
3. 保持段落格式和结构完全一致
4. 技术术语保持原文或使用标准中文译名
5. 保持数学公式、代码块、引用标签不变
6. 直接输出翻译后的完整内容，不要添加任何解释或说明

【英文内容】
$content"

    local response=$(curl -s https://models.inference.ai.azure.com/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"You are a professional translator. Translate LaTeX documents while preserving all commands and formatting.\"},
                {\"role\": \"user\", \"content\": $(echo "$prompt" | jq -Rs .)}
            ],
            \"temperature\": 0.3,
            \"max_tokens\": 8192
        }")
    
    echo "$response" | jq -r '.choices[0].message.content // empty'
}

# Translation function using OpenAI
translate_with_openai() {
    local content="$1"
    local prompt="将下面的 LaTeX 文档从英文翻译成简体中文。

【重要规则】
1. 保持所有 LaTeX 命令不变（\\section{}、\\cite{}、\\ref{}、\\label{} 等）
2. 只翻译文本内容，不翻译命令和参数
3. 保持段落格式和结构完全一致
4. 技术术语保持原文或使用标准中文译名
5. 保持数学公式、代码块、引用标签不变
6. 直接输出翻译后的完整内容，不要添加任何解释或说明

【英文内容】
$content"

    local response=$(curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"You are a professional translator. Translate LaTeX documents while preserving all commands and formatting.\"},
                {\"role\": \"user\", \"content\": $(echo "$prompt" | jq -Rs .)}
            ],
            \"temperature\": 0.3
        }")
    
    echo "$response" | jq -r '.choices[0].message.content // empty'
}

# Translation function using Doubao-seed-code (generic support)
translate_with_doubao() {
    local content="$1"
    local prompt="将下面的 LaTeX 文档从英文翻译成简体中文。

【重要规则】
1. 保持所有 LaTeX 命令不变（\\section{}、\\cite{}、\\ref{}、\\label{} 等）
2. 只翻译文本内容，不翻译命令和参数
3. 保持段落格式和结构完全一致
4. 技术术语保持原文或使用标准中文译名
5. 保持数学公式、代码块、引用标签不变
6. 直接输出翻译后的完整内容，不要添加任何解释或说明

【英文内容】
$content"

    if [ -z "$DOUBAO_URL" ] || [ -z "$DOUBAO_KEY" ]; then
        echo "" >&2
        echo -e "${YELLOW}Warning: DOUBAO_URL or DOUBAO_KEY not set - skipping this call${NC}" >&2
        echo "" >&2
        return 1
    fi
    # Normalize endpoint: if DOUBAO_URL looks like a base URL (no 'chat' path) append /chat/completions
    endpoint="$DOUBAO_URL"
    if [[ "$endpoint" != *"chat"* ]]; then
        # ensure no trailing slash
        endpoint="${endpoint%/}"
        endpoint="$endpoint/chat/completions"
    fi

    # Try common Doubao-like endpoints. User can set DOUBAO_URL to their base URL or full endpoint.
    # For v3 chat-style endpoints, use messages format (role/content)
    response=$(curl -s -X POST "$endpoint" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DOUBAO_KEY" \
        -d "{\"model\": \"$MODEL\", \"messages\": [{\"role\": \"user\", \"content\": $(echo "$prompt" | jq -Rs .)}], \"temperature\": 0.3}")

    # Try to extract common response fields from different providers
    echo "$response" | jq -r '.choices[0].message.content // .choices[0].text // .result // .output[0].content // .data[0].content // .data[0].result // .response // empty'
}

# Test translation function (no external calls) - useful for dry-run
translate_test() {
    local content="$1"
    # For test mode we just prefix the file so you can see it's been processed
    echo "%% TEST TRANSLATION - AutoTranslated (placeholder)"$'\n'
    echo "$content"
}

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required${NC}"
    echo "Install: brew install jq"
    exit 1
fi

# Process each file
success=0
failed=0

for ((i=0; i<total; i++)); do
    en_file="${files[$i]}"
    filename=$(basename "$en_file")
    sc_file="$SC_DIR/$filename"
    
    echo -e "${BLUE}[$((i+1))/$total]${NC} $filename"
    # Read English content
    en_content=$(cat "$en_file")

    # Translate using configured backend
    if [ "$API_TYPE" = "github" ]; then
        translation=$(translate_with_github "$en_content")
    elif [ "$API_TYPE" = "doubao" ]; then
        translation=$(translate_with_doubao "$en_content")
    elif [ "$API_TYPE" = "test" ]; then
        translation=$(translate_test "$en_content")
    else
        translation=$(translate_with_openai "$en_content")
    fi
    
    # Save translation
    if [ -n "$translation" ] && [ "$translation" != "null" ]; then
        echo "$translation" > "$sc_file"
        echo -e "  ${GREEN}✓ Success${NC}"
        ((success++))
    else
        echo -e "  ${RED}✗ Failed${NC}"
        ((failed++))
    fi
    
    # Rate limiting
    sleep 1
    echo ""
done

# Summary
echo -e "${BLUE}╔════════════════════════════════════════╗"
echo "║   Translation Complete!               ║"
echo -e "╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Success: $success${NC}"
echo -e "${RED}✗ Failed: $failed${NC}"
echo ""

if [ $success -gt 0 ]; then
    echo -e "${CYAN}Compile to verify:${NC}"
    echo "  ./scripts/compile_sc.sh"
    echo ""
fi

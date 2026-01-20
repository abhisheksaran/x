#!/usr/bin/env bash

set -euo pipefail

VERSION="1.0.0"

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default model (can be overridden with OLLAMA_MODEL env var)
DEFAULT_MODEL="llama3.2"

# Handle --help flag
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo ""
    echo "Usage: x [options] <instruction>"
    echo ""
    echo "Examples:"
    echo "  x list all git branches"
    echo "  x find files modified in the last 7 days"
    echo "  x show disk usage sorted by size"
    echo "  x count lines in all python files"
    echo ""
    echo "Options:"
    echo "  --verbose    Enable debug output"
    echo "  --version    Show version information"
    echo "  --models     List available Ollama models"
    echo "  --help, -h   Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  OLLAMA_MODEL  Set the model to use (default: $DEFAULT_MODEL)"
    echo ""
    echo "Requires: Ollama (https://ollama.ai)"
    echo "Install:"
    echo "  macOS:  brew install ollama && ollama pull $DEFAULT_MODEL"
    echo "  Linux:  curl -fsSL https://ollama.ai/install.sh | sh && ollama pull $DEFAULT_MODEL"
    exit 0
fi

# Handle --version flag
if [[ "${1:-}" == "--version" ]]; then
    echo "x version $VERSION"
    exit 0
fi

# Handle --models flag
if [[ "${1:-}" == "--models" ]]; then
    echo "Available Ollama models:"
    if command -v ollama &> /dev/null; then
        ollama list 2>/dev/null || echo "  (no models installed - run: ollama pull llama3.2)"
    else
        echo "  Ollama not installed"
    fi
    exit 0
fi

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

OS_TYPE=$(detect_os)

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: Ollama is not installed${NC}"
    echo ""
    echo "Install Ollama:"
    if [[ "$OS_TYPE" == "macos" ]]; then
        echo "  brew install ollama"
    elif [[ "$OS_TYPE" == "ubuntu" ]] || [[ "$OS_TYPE" == "debian" ]]; then
        echo "  curl -fsSL https://ollama.ai/install.sh | sh"
    else
        echo "  curl -fsSL https://ollama.ai/install.sh | sh"
        echo "  (or visit https://ollama.ai for installation instructions)"
    fi
    echo ""
    echo "Then pull a model:"
    echo "  ollama pull $DEFAULT_MODEL"
    exit 1
fi

# Check if Ollama is running
if ! ollama list &> /dev/null; then
    echo -e "${RED}Error: Ollama is not running${NC}"
    echo ""
    echo "Start Ollama:"
    echo "  ollama serve"
    echo ""
    if [[ "$OS_TYPE" == "macos" ]]; then
        echo "Or on macOS, just open the Ollama app."
    elif [[ "$OS_TYPE" == "ubuntu" ]] || [[ "$OS_TYPE" == "debian" ]]; then
        echo "On Ubuntu/Debian, you can also run: sudo systemctl start ollama"
    fi
    exit 1
fi

# Enable debug mode if --verbose flag is passed
DEBUG=0
if [[ "${1:-}" == "--verbose" ]]; then
    DEBUG=1
    shift
fi

# Check if instruction is provided
if [ $# -eq 0 ]; then
    echo "Usage: x [--verbose] <instruction>"
    echo ""
    echo "Example: x list all files modified today"
    echo ""
    echo "Run 'x --help' for more information."
    exit 1
fi

# Combine all arguments into instruction
INSTRUCTION="$*"

# Model to use
MODEL="${OLLAMA_MODEL:-$DEFAULT_MODEL}"

# Check if model is available
if ! ollama list 2>/dev/null | grep -q "^$MODEL"; then
    echo -e "${YELLOW}Model '$MODEL' not found. Pulling it now...${NC}"
    ollama pull "$MODEL" || {
        echo -e "${RED}Failed to pull model '$MODEL'${NC}"
        echo "Try: ollama pull llama3.2"
        exit 1
    }
fi

[[ $DEBUG -eq 1 ]] && echo "DEBUG: Using model: $MODEL" >&2
[[ $DEBUG -eq 1 ]] && echo "DEBUG: Instruction: $INSTRUCTION" >&2

# Build the prompt
PROMPT="You are a shell command generator. Convert the user's natural language instruction into a shell command.

Rules:
- Return ONLY the shell command, nothing else
- No explanations, no markdown formatting, no code block markers
- No backticks, no \`\`\`bash\`\`\`, no comments
- Just the raw executable command(s)
- Use pipes (|) and operators (&&, ||) as needed
- If multiple commands are needed, combine them with && or ;

Context:
- Current directory: $(pwd)
- Shell: ${SHELL}
- OS: $(uname -s)

Instruction: ${INSTRUCTION}

Command:"

[[ $DEBUG -eq 1 ]] && echo "DEBUG: Sending request to Ollama..." >&2

# Call Ollama
RESPONSE=$(ollama run "$MODEL" "$PROMPT" 2>/dev/null)

[[ $DEBUG -eq 1 ]] && echo "DEBUG: Raw response: $RESPONSE" >&2

# Clean up the response (remove potential markdown artifacts)
COMMAND=$(echo "$RESPONSE" | sed 's/^```[a-z]*//g' | sed 's/```$//g' | sed 's/^`//g' | sed 's/`$//g' | tr -d '\n' | xargs)

[[ $DEBUG -eq 1 ]] && echo "DEBUG: Cleaned command: $COMMAND" >&2

if [ -z "$COMMAND" ]; then
    echo -e "${RED}Error: Failed to generate command${NC}"
    echo "Response was: $RESPONSE"
    exit 1
fi

# Display command and ask for confirmation
echo "──────────────────────────────────────"
echo -e "${YELLOW}>>>${NC} $COMMAND"
echo "──────────────────────────────────────"
read -p "Execute? (Y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Cancelled."
    exit 0
else
    echo ""
    eval "$COMMAND"
fi


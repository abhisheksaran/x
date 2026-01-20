# x

A natural language shell command executor powered by Ollama.

Type what you want to do in plain English, and `x` generates and runs the shell command.

## Features

- **100% Local & Free** — Uses Ollama, no API keys needed
- **Private** — Your commands never leave your machine
- **Fast** — No network latency, runs locally
- **Smart** — Auto-downloads models if missing

## Installation

### macOS

```bash
# 1. Install Ollama
brew install ollama

# 2. Pull a model
ollama pull llama3.2

# 3. Install x
curl -sSL https://raw.githubusercontent.com/abhisheksaran/x/main/install.sh | bash
```

### Ubuntu / Debian

```bash
# 1. Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 2. Pull a model
ollama pull llama3.2

# 3. Install x
curl -sSL https://raw.githubusercontent.com/abhisheksaran/x/main/install.sh | bash
```

### Manual Installation

```bash
git clone git@github.com:abhisheksaran/x.git
sudo cp x/x /usr/local/bin/x
```

## Usage

```bash
x <what you want to do>
```

### Examples

```bash
x list all git branches
x find files modified in the last 7 days
x show disk usage sorted by size
x count lines in all python files
x show my public IP address
x compress this folder into a zip
```

The script shows the generated command and asks for confirmation before executing.

## Options

```bash
x --help       # Show help
x --version    # Show version
x --verbose    # Enable debug output
x --models     # List available Ollama models
```

## Use a Different Model

```bash
# One-time
OLLAMA_MODEL=mistral x find large files

# Permanent (add to ~/.zshrc or ~/.bashrc)
export OLLAMA_MODEL=qwen2.5-coder
```

### Recommended Models

| Model | Size | Best For |
|-------|------|----------|
| `llama3.2` | ~2GB | Fast, good for simple commands |
| `mistral` | ~4GB | Great reasoning |
| `qwen2.5-coder` | ~4GB | Excellent for code/shell |

## Requirements

- [Ollama](https://ollama.ai) installed and running
- macOS, Linux, or WSL

## License


MIT
## Test 



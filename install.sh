#!/bin/bash

set -e

INSTALL_DIR="/usr/local/bin"
REPO_URL="https://raw.githubusercontent.com/abhisheksaran/x/main/x"

echo "Installing x..."

# Download the script
if command -v curl &> /dev/null; then
    curl -sSL -o /tmp/x "$REPO_URL"
elif command -v wget &> /dev/null; then
    wget -q -O /tmp/x "$REPO_URL"
else
    echo "Error: Neither curl nor wget is available"
    exit 1
fi

# Install
chmod +x /tmp/x
sudo mv /tmp/x "$INSTALL_DIR/x"

echo ""
echo "✓ Installed x to $INSTALL_DIR/x"
echo ""
echo "Make sure Ollama is installed and running:"
echo "  brew install ollama"
echo "  ollama pull llama3.2"
echo ""
echo "Then try:"
echo "  x list all files in this directory"


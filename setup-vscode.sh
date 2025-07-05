#!/usr/bin/env bash
#set -euo pipefail

# ------------------------------
# Install VSCode
# ------------------------------
echo "🔧 Setting up VSCode repository cleanly..."

# The official way - documented at https://code.visualstudio.com/docs/setup/linux 
# My way: Remove potential conflicting old entries
sudo rm -f /etc/apt/sources.list.d/vscode.sources
sudo rm -f /usr/share/keyrings/microsoft.gpg

# Re-add Microsoft GPG key with consistent filename
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null

# Add repo only if not present
if ! grep -q "packages.microsoft.com" /etc/apt/sources.list.d/vscode.list 2>/dev/null; then
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
fi

# Install VSCode
sudo apt update
sudo apt install -y code

# Install VSCode extensions
echo "⬇️ Installing VSCode extensions..."

if command -v code >/dev/null; then
    curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/vscode-extensions.txt | while read -r extension; do
        [ -n "$extension" ] && code --install-extension "$extension"
    done
    echo "✅ VSCode extensions installed."
else
    echo "⚠️ VSCode CLI 'code' not found. Skipping extensions."
fi

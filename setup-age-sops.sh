#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing Age, SOPS, GnuPG..."

# Install dependencies
sudo apt update
sudo apt install -y gnupg age curl unzip jq

# Check if SOPS is present via apt
if command -v sops >/dev/null; then
    CURRENT_VERSION=$(sops --version | grep -oP '\d+\.\d+\.\d+')
    echo "📝 Found existing SOPS version: $CURRENT_VERSION (likely from apt)"
else
    echo "⚠️ SOPS not found, proceeding with manual installation."
fi

# Install latest SOPS manually for consistency
echo "⬇️ Fetching latest SOPS release info..."
LATEST_URL=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | jq -r '.assets[] | select(.name | test("linux.*amd64$")) | .browser_download_url')

if [ -z "$LATEST_URL" ]; then
    echo "❌ Failed to determine latest SOPS binary URL."
    exit 1
fi

echo "⬇️ Downloading SOPS from: $LATEST_URL"
curl -Lo sops "$LATEST_URL"
chmod +x sops
sudo mv sops /usr/local/bin/sops

echo "✅ Installed latest SOPS."

# Show versions
echo
echo "Installed tool versions:"
echo " - sops: $(sops --version --check-for-updates)"
echo " - age : $(age --version)"
echo " - gpg : $(gpg --version | head -n 1)"

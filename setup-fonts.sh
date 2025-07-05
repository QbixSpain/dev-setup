#!/usr/bin/env bash
# set -e

# Fonts avaiable from here
# https://www.nerdfonts.com/font-downloads
# If you need one, go to the website and check what filename the link is pointing to

echo "📦 Installing Nerd Fonts..."

# Temp folder for downloads
TEMP_DIR="$(mktemp -d)"
FONT_DIR="$HOME/.local/share/fonts"
URL_PREFIX="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

# Fonts to download
FONT_LIST=(
    "0xProto.zip"
    "FiraCode.zip"
    "JetBrainsMono.zip"
    "Meslo.zip"
)

mkdir -p "$FONT_DIR"
cd "$TEMP_DIR"

# Download fonts paraller
printf "%s\n" "${FONT_LIST[@]}" | parallel -j4 \
  'echo "⬇️ Downloading {}..."; curl -sSfLO "$URL_PREFIX/{}"'


# Download and extract
for FONT_FILE in "${FONT_LIST[@]}"; do
    echo "⬇️ Downloading $FONT_FILE..."
    curl -sSfLO "$URL_PREFIX/$FONT_FILE"
done

for ARCHIVE in *.zip; do
    echo "📂 Extracting $ARCHIVE..."
    unzip -o -q "$ARCHIVE" -d "$FONT_DIR"
done


# Refresh font cache
echo "🔄 Updating font cache..."
fc-cache -fv > /dev/null

# Cleanup
cd ~
rm -rf "$TEMP_DIR"

echo "✅ Fonts installed successfully."

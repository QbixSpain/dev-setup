#!/bin/bash
#set -e

echo "This will setup dev tools and enviroment."

# Pre-cache sudo at start
sudo -v

# Optional keep-alive for long scripts
( while true; do sudo -n true; sleep 60; done ) 2>/dev/null &

# ------------------------------
# Config Section
# ------------------------------
SETUP_ALIAS="${SETUP_ALIAS:-ON}"
APT="nala"

# Detect OS
OS_TYPE=$(uname -s)

if [[ "$OS_TYPE" == "Darwin" ]]; then
    PLATFORM="mac"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    PLATFORM="linux"
else
    echo "❌ Unsupported OS: $OS_TYPE"
    exit 1
fi

echo "🖥️ Detected platform: $PLATFORM"


# ------------------------------
# Helper Section
# ------------------------------
install_script() {
    local PACKAGE_NAME="$1"
    local CMD_NAME="$2"
    local INSTALL_COMMAND="$3"

    if ! command -v "$CMD_NAME" >/dev/null 2>&1; then
        echo "🔧 Installing $PACKAGE_NAME..."
        eval "$INSTALL_COMMAND"
        echo "✅ $PACKAGE_NAME installed."
    else
        echo "🍺 $PACKAGE_NAME already installed."
    fi
}

install_zsh_alias() {
    local ALIAS_LINE="$1"
    local ZSHRC_FILE="${HOME}/.zshrc"

    if ! grep -Fxq "$ALIAS_LINE" "$ZSHRC_FILE"; then
        echo "$ALIAS_LINE" >> "$ZSHRC_FILE"
        echo "✅ Added '$ALIAS_LINE' to $ZSHRC_FILE"
    fi
}


# ------------------------------------------------------------------------------
# install_latest_deb
#
# Installs the latest .deb package from a GitHub release.
#
# Usage:
#   install_latest_deb "owner/repo" "filter" "output.deb"
#
# Example:
#   install_latest_deb "sharkdp/fd" "amd64.deb" "fd.deb"
#
# Parameters:
#   $1 = GitHub repository in the format "owner/repo"
#   $2 = String filter to match the correct asset (e.g. "amd64.deb")
#   $3 = Local filename to save the downloaded .deb file
#
# Notes:
# - Uses GitHub's API to find the latest release
# - Downloads matching asset via `wget`
# - Installs it using `dpkg`, and auto-fixes missing deps with `nala`
# - Cleans up the temporary .deb file
# - Prints status messages with emojis for visibility
# - Works best on Debian/Ubuntu-based systems
# ------------------------------------------------------------------------------

install_latest_deb() {
    local repo="$1"
    local pattern="$2"
    local output="$3"

    echo "🔍 Fetching latest release of $repo..."

    local url
    url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" \
        | grep browser_download_url \
        | grep "$pattern" \
        | cut -d '"' -f 4)

    if [[ -z "$url" ]]; then
        echo "❌ Could not find matching .deb package for $repo"
        return 1
    fi

    echo "⬇️  Downloading: $url"
    wget -q "$url" -O "$output"
    echo "📦 Installing $output..."
    sudo dpkg -i "$output" || sudo $APT -f install -y
    rm -f "$output"
}


set_rc_var() {
    local FILE="$1"
    local VAR="$2"
    local VALUE="$3"

    if grep -q "^${VAR}=" "$FILE"; then
        sed -i "s|^${VAR}=.*|${VAR}=\"${VALUE}\"|" "$FILE"
    else
        echo "${VAR}=\"${VALUE}\"" >> "$FILE"
    fi
}

ask_reboot() {
    local choice
    choice=$(printf "Cancel\nREBOOT" | fzf --height=6 --reverse --border --prompt="⟳ Reboot now? → ")

    if [[ "$choice" == "REBOOT" ]]; then
        echo "⟳ Rebooting..."
        sudo reboot
    else
        echo "❌ Reboot skipped. Please reboot manually to apply changes."
    fi
}

apply_shell_config() {
#    case "$SHELL" in
#    */bash) [ -f ~/.bashrc ] && source ~/.bashrc ;;
#    */zsh)  [ -f ~/.zshrc ] && source ~/.zshrc ;;
#    esac

   source ~/.bashrc  # bash
   source ~/.zshrc   # zsh
}


# ------------------------------------
# Ubuntu: Dark mode on
# ------------------------------------
echo "🌙 Setting dark mode..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Uninstall snaps
echo "Removing thunderbird and rhythmbox..."
sudo snap list thunderbird >/dev/null 2>&1 && sudo snap remove --purge thunderbird
sudo snap list rhythmbox >/dev/null 2>&1 && sudo snap remove --purge rhythmbox

# DOCK Favorite Apps
gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'brave-browser.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'code.desktop']"

# ------------------------------------
# Install nala first
# ------------------------------------
sudo apt install -y nala

# Install brave 
echo "🔧 Installing Brave browser..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo $APT update
sudo $APT install -y brave-browser

# ------------------------------
# Installation Section
# ------------------------------

echo "🔧 Installing Git..."
sudo $APT install -y git gh

echo "🔧 Installing Curl, build-essential, gpg, wget"
sudo $APT install -y --no-install-recommends curl build-essential gpg wget

echo "🔧 Installing Open-vm-tools.."
sudo $APT install -y open-vm-tools open-vm-tools-desktop

echo "🔧 Installing mc..."
sudo $APT install -y mc

echo "🔧 Installing DB Browser for SQLite..."
sudo $APT install -y sqlitebrowser


# ------------------------------
# Terminal Setup
# ------------------------------

# Install zsh
echo "🔧 Installing zsh..."
sudo $APT install -y zsh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10K Zsh Theme
echo "🎨 Download Powerlevel10k Theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" 

# Download Zsh and  Powerlevel10k config
echo "⬇️ Downloading .zshrc..."
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/.zshrc -o ~/.zshrc

echo "⬇️ Downloading .p10k.zsh..."
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/.p10k.zsh -o ~/.p10k.zsh

echo "✅ Zsh configuration downloaded."


# Install fancy fonts from 
# https://www.nerdfonts.com/font-downloads
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/setup-fonts.sh | bash


# Make zsh default shell
sudo chsh -s "$(which zsh)" $USER

# Install fzf
echo "🔧 Installing fzf..."

[ -d ~/.fzf ] && rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
apply_shell_config

echo "✅ fzf installed: $(fzf --version)"


# Install some terminal utilities

# Install zoxide, bat, figlet
echo "🔧 Installing zoxide, bat, figlet, btop micro..."
sudo $APT install -y zoxide bat figlet btop micro

# fastfetch - system info
echo "🔧 Installing fasfetch..."
install_latest_deb "fastfetch-cli/fastfetch" "amd64.deb" "fastfetch.deb"

# onefetch - git info
echo "🔧 Installing onefetch..."
install_latest_deb "o2sh/onefetch" "amd64.deb" "onefetch.deb"

# glow for cli markdown rendering
echo "🔧 Installing glow..."
install_latest_deb "charmbracelet/glow" "amd64.deb" "glow.deb"


# ------------------------------
# Gnome Setup
# ------------------------------

# Setup Blur My Windows
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/setup-gnome-hexagons.sh | bash

# Download gnome terminal config

echo "⬇️ Downloading GNOME Terminal config..."
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/gnome-terminal.conf -o ~/.gnome-terminal-pending.conf
# Hint:
# read conf : dconf dump /org/gnome/terminal/ > terminal.conf
# write conf: dconf dump /org/gnome/terminal/ > terminal.conf

# ------------------------------
# Dev Tools Setup
# ------------------------------

echo "🔧 Installing Rust and Cargo..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

source "$HOME/.cargo/env"

echo "🔧 Installing eza with cargo..."
cargo install eza


echo "⚙️ Installing Age, SOPS, GnuPG..."
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/setup-age-sops.sh | bash

echo "🔧 Installing YubiKey Manager..."
sudo $APT-add-repository -y ppa:yubico/stable
sudo $APT update
sudo $APT install -y yubikey-manager
echo "✅ ykman installed: $(ykman --version)"

# ------------------------------
# Install vscode
# ------------------------------
echo "⚙️ Installing VSCode and extensions..."
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/setup-vscode.sh | bash

# ------------------------------
# Python Dev Tools Setup
# ------------------------------

echo "🔧 Installing pipx..."
sudo $APT install -y --no-install-recommends python3-venv pipx
pipx ensurepath

echo "🔧 Installing ruff..."
pipx install ruff

echo "🔧 Installing uv..."
curl -Ls https://astral.sh/uv/install.sh | sh


# ------------------------------
# Automotive Dev Tools Setup
# ------------------------------

# GCC for ARM
echo "🔧 Installing gcc-arm-none-eabi..."
sudo $APT install -y gcc-arm-none-eabi

echo "🔧 Installing cmake..."
sudo $APT install -y cmake

echo "🔧 Installing Ninja build system..."
sudo $APT install -y ninja-build

echo "🔧 Installing picocom..."
sudo $APT install -y picocom

# Setup Segger JLink and Ozone Debugger
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/setup-jlink.sh | bash

echo "🔧 Installing sigrok..."
sudo $APT install -y pulseview sigrok-cli

# ------------------------------
# Automotive CAN Tools Setup
# ------------------------------

# Installing can-utils (like cansend, candumop etc)
echo "🔧 Installing can-utils..."
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/setup-can-utils.sh | bash

echo "🔧 Setting up can devices without sudo need..."
curl -sSfL https://raw.githubusercontent.com/QbixSpain/dev-setup/main/setup-can-sudoers.sh | bash

# ------------------------------
# Network Tools Setup
# ------------------------------

echo "🔧 Installing WireShark..."
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo $APT install -y wireshark

# ------------------------------
# Installation Complete
# ------------------------------

echo "Please reboot to take full advantage of new changes"

ask_reboot

figlet 'Setup done!'

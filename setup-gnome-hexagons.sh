#!/bin/bash
set -e

echo "🔧 Installing GNOME extensions CLI and dependencies..."
sudo apt install -y gnome-shell-extensions gnome-shell-extension-prefs chrome-gnome-shell

echo "🌐 Installing Burn My Windows extension..."
# https://github.com/Schneegans/Burn-My-Windows

EXT_ZIP="burn-my-windows@schneegans.github.com.zip"

wget -O "$EXT_ZIP" https://github.com/Schneegans/Burn-My-Windows/releases/latest/download/$EXT_ZIP
gnome-extensions install "$EXT_ZIP"
rm -f "$EXT_ZIP"

# This shall be done after log out/log in
# gnome-extensions enable burn-my-windows@schneegans.github.com

# This is not working yet..
# echo "🎨 Setting Hexagons preset..."
# gsettings set org.gnome.shell.extensions.burn-my-windows.default-preset 'Hexagons'

echo "✅ Burn My Windows with Hexagons installed!"
#!/usr/bin/env bash

echo "🔧 Installing latest cmake..."

echo "[kitware] Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates gpg wget

echo "[kitware] Adding Kitware signing key..."
test -f /usr/share/doc/kitware-archive-keyring/copyright || \
    wget -qO- https://apt.kitware.com/keys/kitware-archive-latest.asc \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null

echo "[kitware] Adding the Kitware APT repository for Ubuntu 24.04..."
echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ noble main" \
    | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

echo "[kitware] Updating apt lists..."
sudo apt-get update -y

echo "[kitware] Installing CMake from Kitware repo..."
sudo apt-get install -y cmake

echo "[kitware] Installed CMake version:"
cmake --version

echo "[kitware] Done!"

#!/usr/bin/env bash
set -euo pipefail

echo "\n🔧 Configuring sudoers for CAN interface control..."

USER_NAME=$(whoami)
IP_PATH=$(which ip)
CAN_SUDOERS="/etc/sudoers.d/can-interfaces"

SUDOERS_LINE_0="$USER_NAME ALL=(ALL) NOPASSWD: $IP_PATH link set can0*"
SUDOERS_LINE_1="$USER_NAME ALL=(ALL) NOPASSWD: $IP_PATH link set can1*"

# Check if already configured
if sudo grep -q "$IP_PATH link set can0" "$CAN_SUDOERS" 2>/dev/null; then
    echo "⚠️ CAN sudoers permissions already configured."
    exit 0
fi

echo "⬇️ Adding CAN sudoers rules..."
{
    echo "$SUDOERS_LINE_0"
    echo "$SUDOERS_LINE_1"
} | sudo tee "$CAN_SUDOERS" > /dev/null

sudo chmod 440 "$CAN_SUDOERS"

echo "🔎 Validating sudoers file..."
if sudo visudo -cf "$CAN_SUDOERS"; then
    echo "✅ CAN sudoers permissions applied safely."
else
    echo "❌ Syntax error detected, removing file."
    sudo rm -f "$CAN_SUDOERS"
    exit 1
fi

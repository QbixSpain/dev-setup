echo "🔧 Installing SEGGER J-Link and Ozone..."

# URLs for latest installers
JLINK_URL="https://www.segger.com/downloads/jlink/JLink_Linux_x86_64.deb"
OZONE_URL="https://www.segger.com/downloads/jlink/Ozone_Linux_x86_64.deb"

# Temporary paths
JLINK_DEB="/tmp/JLink_Linux.deb"
OZONE_DEB="/tmp/Ozone_Linux.deb"

# Install J-Link
wget -O "$JLINK_DEB" "$JLINK_URL"
sudo dpkg -i "$JLINK_DEB"
rm "$JLINK_DEB"

# Install Ozone
wget -O "$OZONE_DEB" "$OZONE_URL"
sudo dpkg -i "$OZONE_DEB"
rm "$OZONE_DEB"

echo "✅ SEGGER J-Link and Ozone installed."

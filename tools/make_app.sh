#!/bin/sh
# Builds Labyrinth.app: a double-click start for this repo.
# The app runs ./play from this folder with the brew Godot. It holds no copy
# of the game, so it stays in step with the repo. If you move the repo, run
# this script again.
#
# Usage: tools/make_app.sh [destination folder]   (default: ~/Applications)
set -eu

repo=$(cd "$(dirname "$0")/.." && pwd)
dest=${1:-"$HOME/Applications"}
app="$dest/Labyrinth.app"
icon_src="$repo/assets/sprites/friends/crab.png"

mkdir -p "$dest"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

# Finder starts an app with a short PATH that has no /opt/homebrew/bin.
# The log keeps the Godot output, because an app has no terminal.
cat > "$app/Contents/MacOS/Labyrinth" <<EOF
#!/bin/sh
export PATH="/opt/homebrew/bin:/usr/local/bin:\$PATH"
log="\$HOME/Library/Logs/Labyrinth.log"
exec "$repo/play" >"\$log" 2>&1
EOF
chmod +x "$app/Contents/MacOS/Labyrinth"

cat > "$app/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key><string>Labyrinth</string>
	<key>CFBundleDisplayName</key><string>Labyrinth</string>
	<key>CFBundleIdentifier</key><string>local.labyrinth.launcher</string>
	<key>CFBundleExecutable</key><string>Labyrinth</string>
	<key>CFBundleIconFile</key><string>Labyrinth</string>
	<key>CFBundlePackageType</key><string>APPL</string>
	<key>CFBundleVersion</key><string>1</string>
	<key>LSMinimumSystemVersion</key><string>11.0</string>
</dict>
</plist>
EOF

# Icon: the crab sprite, padded to a transparent square.
tmp=$(mktemp -d)
iconset="$tmp/Labyrinth.iconset"
mkdir -p "$iconset"
sips -s format png --padToHeightWidth 512 512 "$icon_src" --out "$tmp/square.png" >/dev/null
for size in 16 32 128 256 512; do
	sips -z "$size" "$size" "$tmp/square.png" --out "$iconset/icon_${size}x${size}.png" >/dev/null
	double=$((size * 2))
	sips -z "$double" "$double" "$tmp/square.png" --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$iconset" -o "$app/Contents/Resources/Labyrinth.icns"
rm -rf "$tmp"

# Make Finder read the new icon and plist.
touch "$app"
echo "Built $app"

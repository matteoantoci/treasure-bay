#!/bin/sh
# Builds "Treasure Bay.app": a double-click start for this repo.
# The app runs ./play from this folder with the brew Godot. It holds no copy
# of the game, so it stays in step with the repo. If you move the repo, run
# this script again. An old Labyrinth.app from an earlier version of this
# script stays in the destination folder. Delete it by hand.
#
# Usage: tools/make_app.sh [destination folder]   (default: ~/Applications)
set -eu

name="Treasure Bay"
repo=$(cd "$(dirname "$0")/.." && pwd)
dest=${1:-"$HOME/Applications"}
app="$dest/$name.app"
icon_src="$repo/assets/sprites/friends/crab.png"

mkdir -p "$dest"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

# Finder starts an app with a short PATH that has no /opt/homebrew/bin.
# The log keeps the Godot output, because an app has no terminal.
cat > "$app/Contents/MacOS/$name" <<EOS
#!/bin/sh
export PATH="/opt/homebrew/bin:/usr/local/bin:\$PATH"
log="\$HOME/Library/Logs/$name.log"
exec "$repo/play" >"\$log" 2>&1
EOS
chmod +x "$app/Contents/MacOS/$name"

cat > "$app/Contents/Info.plist" <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key><string>$name</string>
	<key>CFBundleDisplayName</key><string>$name</string>
	<key>CFBundleIdentifier</key><string>local.treasure-bay.launcher</string>
	<key>CFBundleExecutable</key><string>$name</string>
	<key>CFBundleIconFile</key><string>$name</string>
	<key>CFBundlePackageType</key><string>APPL</string>
	<key>CFBundleVersion</key><string>1</string>
	<key>LSMinimumSystemVersion</key><string>11.0</string>
</dict>
</plist>
EOS

# Icon: the crab sprite, padded to a transparent square.
tmp=$(mktemp -d)
iconset="$tmp/$name.iconset"
mkdir -p "$iconset"
sips -s format png --padToHeightWidth 512 512 "$icon_src" --out "$tmp/square.png" >/dev/null
for size in 16 32 128 256 512; do
	sips -z "$size" "$size" "$tmp/square.png" --out "$iconset/icon_${size}x${size}.png" >/dev/null
	double=$((size * 2))
	sips -z "$double" "$double" "$tmp/square.png" --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$iconset" -o "$app/Contents/Resources/$name.icns"
rm -rf "$tmp"

# Make Finder read the new icon and plist.
touch "$app"
echo "Built $app"

#!/usr/bin/env bash
set -e

SRC="${1:-assets/icon/app_icon.png}"

if [ ! -f "$SRC" ]; then
  echo "Error: Source icon not found at $SRC"
  exit 1
fi

echo "Generating icons from $SRC ..."

# Ensure directories exist
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset

# Android Launcher Icons
echo "Generating Android mipmaps..."
sips -z 48 48 "$SRC" --out android/app/src/main/res/mipmap-mdpi/ic_launcher.png > /dev/null
sips -z 72 72 "$SRC" --out android/app/src/main/res/mipmap-hdpi/ic_launcher.png > /dev/null
sips -z 96 96 "$SRC" --out android/app/src/main/res/mipmap-xhdpi/ic_launcher.png > /dev/null
sips -z 144 144 "$SRC" --out android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png > /dev/null
sips -z 192 192 "$SRC" --out android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png > /dev/null

# Also copy to ic_launcher_round.png for devices requesting roundIcon
cp android/app/src/main/res/mipmap-mdpi/ic_launcher.png android/app/src/main/res/mipmap-mdpi/ic_launcher_round.png
cp android/app/src/main/res/mipmap-hdpi/ic_launcher.png android/app/src/main/res/mipmap-hdpi/ic_launcher_round.png
cp android/app/src/main/res/mipmap-xhdpi/ic_launcher.png android/app/src/main/res/mipmap-xhdpi/ic_launcher_round.png
cp android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png
cp android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png

# iOS App Icons
echo "Generating iOS AppIcon set..."
sips -z 20 20 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png > /dev/null
sips -z 40 40 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png > /dev/null
sips -z 60 60 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png > /dev/null

sips -z 29 29 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png > /dev/null
sips -z 58 58 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png > /dev/null
sips -z 87 87 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png > /dev/null

sips -z 40 40 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png > /dev/null
sips -z 80 80 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png > /dev/null
sips -z 120 120 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png > /dev/null

sips -z 120 120 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png > /dev/null
sips -z 180 180 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png > /dev/null

sips -z 76 76 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png > /dev/null
sips -z 152 152 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png > /dev/null

sips -z 167 167 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png > /dev/null

sips -z 1024 1024 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png > /dev/null

echo "All icons generated successfully!"

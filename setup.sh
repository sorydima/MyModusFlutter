#!/usr/bin/env bash
set -e
echo "=== My Modus Monorepo setup ==="
if ! command -v flutter &> /dev/null; then
  echo "Flutter not found. Install Flutter and add to PATH."
  exit 1
fi
FRONTEND_DIR="$(pwd)/frontend"
cd "$FRONTEND_DIR"
# Remove existing platform folders to avoid plist or platform conflicts
echo "Removing existing platform folders (if any) to ensure clean flutter create..."
rm -rf android ios web macos windows linux
echo "Running: flutter create ."
flutter create .
echo "Running pub get..."
flutter pub get
echo "Generating launcher icons and native splash..."
# Use dart run for newer pub tooling if available
if command -v dart &> /dev/null; then
  dart run flutter_launcher_icons:main || flutter pub run flutter_launcher_icons:main
  dart run flutter_native_splash:create || flutter pub run flutter_native_splash:create
else
  flutter pub run flutter_launcher_icons:main
  flutter pub run flutter_native_splash:create
fi
echo "Setup complete."

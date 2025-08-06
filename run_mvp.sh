#!/bin/bash

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Run the MVP version
echo "Running My Modus MVP version..."
flutter run -t lib/main_mvp.dart 
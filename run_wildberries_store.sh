#!/bin/bash

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Run the Wildberries store app
echo "Running My Modus Wildberries Store..."
flutter run -t lib/main_wildberries.dart 
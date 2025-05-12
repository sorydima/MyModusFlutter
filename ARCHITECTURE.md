# 🏗 App Architecture

## 🔄 Structure

```
lib/
├── models/            # Data models
├── screens/           # UI screens
├── widgets/           # Reusable UI components
├── data/              # API and service classes
├── providers/         # State management (Provider)
├── utils/             # Helper functions and constants
└── main.dart          # Entry point
```

## 🧱 State Management
Uses the **Provider** package to manage app state in a scalable and modular way.

## 🔧 API Layer
The `data/` folder contains service classes that handle HTTP requests using the `http` package.

## 📦 Local Storage (Planned)
Will use `shared_preferences` or `hive` for storing user preferences and cached data.
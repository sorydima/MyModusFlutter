# My Modus MVP

This is a simplified MVP (Minimum Viable Product) version of the My Modus Flutter app based on the library from `/home/sorydev/Загрузки/my_modus_mvp/frontend/lib`.

## Features

- **Product Grid Display**: Shows products in a responsive grid layout
- **API Integration**: Fetches products from a backend API
- **Product Cards**: Displays product information with images, titles, and prices
- **External Links**: Opens product links in external browser
- **Cross-Platform**: Works on iOS, Android, and Web

## Project Structure

```
lib/
├── main_mvp.dart          # MVP entry point
├── models/
│   └── product.dart       # Product data model
├── services/
│   └── api_service.dart   # API service for fetching products
├── screens/
│   └── home_screen.dart   # Main home screen
└── widgets/
    └── product_card.dart  # Product card widget
```

## Getting Started

### Prerequisites

- Flutter SDK installed
- Backend API running on `http://127.0.0.1:8000`

### Running the MVP

1. **Using the script:**
   ```bash
   ./run_mvp.sh
   ```

2. **Manual run:**
   ```bash
   export PATH="$HOME/flutter/bin:$PATH"
   flutter run -t lib/main_mvp.dart
   ```

### API Requirements

The app expects a backend API with the following endpoint:
- `GET /products` - Returns a JSON object with a `products` array

Example response:
```json
{
  "products": [
    {
      "title": "Product Name",
      "price": 1000,
      "oldPrice": 1200,
      "discount": 20,
      "image": "https://example.com/image.jpg",
      "link": "https://example.com/product"
    }
  ]
}
```

## Dependencies

The MVP uses the following key dependencies:
- `http: ^1.1.0` - For API calls
- `url_launcher: ^6.0.17` - For opening external links
- `flutter/material.dart` - For UI components

## Differences from Full App

This MVP version is a simplified version of the main My Modus app:
- Focused on core product display functionality
- Minimal UI with essential features only
- Direct API integration without complex state management
- No additional features like ads, notifications, or advanced navigation

## Development

To modify the MVP:
1. Edit the relevant files in the `lib/` directory
2. Update the API endpoint in `services/api_service.dart` if needed
3. Run the app using the provided script or manual commands

## Platform Support

- ✅ iOS
- ✅ Android  
- ✅ Web
- ✅ macOS
- ✅ Linux
- ✅ Windows 
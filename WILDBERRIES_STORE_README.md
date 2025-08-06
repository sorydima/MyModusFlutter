# My Modus - Wildberries Store App

This is a Flutter app specifically designed for the My Modus brand store on Wildberries (https://www.wildberries.ru/brands/311036101-my-modus).

## 🎯 Features

- **Real-time Product Data**: Fetches live product data from Wildberries API
- **Category Filtering**: Filter products by category (Clothing, Shoes, Accessories, Sports)
- **Product Cards**: Beautiful product cards with images, prices, and discount badges
- **Direct Links**: Opens product pages directly on Wildberries
- **Responsive Design**: Works perfectly on mobile, tablet, and web
- **Pull-to-Refresh**: Refresh product data with pull gesture
- **Error Handling**: Graceful error handling with retry options

## 📱 Screenshots

The app features:
- Purple theme matching Wildberries branding
- Category filter chips at the top
- Product grid with discount badges
- Loading and error states
- Responsive layout for all screen sizes

## 🏗️ Project Structure

```
lib/
├── main_wildberries.dart              # Wildberries store entry point
├── models/
│   └── product.dart                   # Product model with Wildberries support
├── services/
│   └── wildberries_api_service.dart   # Wildberries API integration
├── screens/
│   └── wildberries_store_screen.dart  # Main store screen
└── widgets/
    └── product_card.dart              # Enhanced product card widget
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Internet connection for API calls

### Running the App

1. **Using the script:**
   ```bash
   ./run_wildberries_store.sh
   ```

2. **Manual run:**
   ```bash
   export PATH="$HOME/flutter/bin:$PATH"
   flutter run -t lib/main_wildberries.dart
   ```

## 🔗 API Integration

The app integrates with Wildberries search API:
- **Base URL**: `https://search.wb.ru/exactmatch/ru/common/v4/search`
- **Brand ID**: `311036101` (My Modus)
- **Categories**: Clothing (8126), Shoes (8127), Accessories (8128), Sports (8129)

### API Features

- Real-time product data from Wildberries
- Price conversion (kopeks to rubles)
- Discount calculation
- Image URL generation
- Product link generation

## 🎨 UI/UX Features

### Product Cards
- Rounded corners and shadows
- Discount badges for products on sale
- Error handling for broken images
- Price comparison (current vs old price)
- Touch feedback

### Category Filter
- Horizontal scrollable filter chips
- Visual selection indicators
- Instant category switching

### Loading States
- Loading spinner with brand message
- Error states with retry buttons
- Empty state for no products found

## 📊 Data Structure

### Product Model
```dart
class Product {
  final String title;        // Product name
  final int? price;          // Current price in rubles
  final int? oldPrice;       // Original price in rubles
  final int? discount;       // Discount percentage
  final String? image;       // Product image URL
  final String link;         // Wildberries product link
}
```

## 🔧 Configuration

### API Endpoints
- Main search: `/exactmatch/ru/common/v4/search`
- Category filtering: Same endpoint with category parameter
- Image URLs: `https://images.wbstatic.net/c246x328/new/{id}-1.jpg`

### Brand Settings
- Brand Name: "My Modus"
- Brand ID: "311036101"
- Store URL: "https://www.wildberries.ru/brands/311036101-my-modus"

## 🛠️ Development

### Adding New Categories
1. Update the `categories` map in `wildberries_store_screen.dart`
2. Add the category ID to the Wildberries API call

### Customizing the Theme
1. Modify the `ThemeData` in `main_wildberries.dart`
2. Update colors, fonts, and styling as needed

### API Modifications
1. Edit `wildberries_api_service.dart` for API changes
2. Update the `Product.fromWildberriesJson()` method for data structure changes

## 📱 Platform Support

- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ macOS
- ✅ Linux
- ✅ Windows

## 🔍 Troubleshooting

### Common Issues

1. **No products loading**
   - Check internet connection
   - Verify Wildberries API is accessible
   - Try refreshing the app

2. **Images not loading**
   - Images are loaded from Wildberries CDN
   - Check if product has valid image ID
   - App shows placeholder for missing images

3. **API errors**
   - Wildberries may rate limit requests
   - Try again after a few minutes
   - Check if API structure has changed

## 📈 Future Enhancements

- Product search functionality
- Wishlist feature
- Price tracking
- Push notifications for sales
- Offline caching
- User reviews integration
- Size and color filtering

## 📞 Support

For issues or questions about the Wildberries store app:
1. Check the troubleshooting section
2. Verify API connectivity
3. Test on different platforms
4. Review the error messages in the app

## 🔗 Links

- **Wildberries Brand Page**: https://www.wildberries.ru/brands/311036101-my-modus
- **Wildberries API**: https://search.wb.ru/exactmatch/ru/common/v4/search
- **Flutter Documentation**: https://flutter.dev/docs 
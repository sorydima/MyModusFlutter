import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  String _searchQuery = '';
  String _selectedCategory = 'Все';
  String _selectedSort = 'Популярные';
  double _minPrice = 0;
  double _maxPrice = 100000;
  bool _showFilters = false;

  final List<String> _categories = ['Все', 'Обувь', 'Одежда', 'Аксессуары', 'Электроника', 'Спорт', 'Красота'];
  final List<String> _sortOptions = ['Популярные', 'По цене ↑', 'По цене ↓', 'По рейтингу', 'По новизне'];

  // Тестовые данные для поиска
  final List<Map<String, dynamic>> _allProducts = [
    {
      'id': '1',
      'title': 'Nike Air Max 270',
      'price': 12990,
      'oldPrice': 15990,
      'discount': 19,
      'imageUrl': 'https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=Nike+Air+Max+270',
      'brand': 'Nike',
      'rating': 4.8,
      'reviewCount': 127,
      'category': 'Обувь',
    },
    {
      'id': '2',
      'title': 'Adidas Ultraboost 22',
      'price': 18990,
      'oldPrice': null,
      'discount': null,
      'imageUrl': 'https://via.placeholder.com/400x400/4ECDC4/FFFFFF?text=Adidas+Ultraboost+22',
      'brand': 'Adidas',
      'rating': 4.9,
      'reviewCount': 89,
      'category': 'Обувь',
    },
    {
      'id': '3',
      'title': 'Levi\'s 501 Original Jeans',
      'price': 7990,
      'oldPrice': 9990,
      'discount': 20,
      'imageUrl': 'https://via.placeholder.com/400x400/45B7D1/FFFFFF?text=Levis+501+Jeans',
      'brand': 'Levi\'s',
      'rating': 4.6,
      'reviewCount': 203,
      'category': 'Одежда',
    },
    {
      'id': '4',
      'title': 'Apple Watch Series 8',
      'price': 45990,
      'oldPrice': 49990,
      'discount': 8,
      'imageUrl': 'https://via.placeholder.com/400x400/96CEB4/FFFFFF?text=Apple+Watch+Series+8',
      'brand': 'Apple',
      'rating': 4.7,
      'reviewCount': 156,
      'category': 'Электроника',
    },
    {
      'id': '5',
      'title': 'Samsung Galaxy S23',
      'price': 89990,
      'oldPrice': 99990,
      'discount': 10,
      'imageUrl': 'https://via.placeholder.com/400x400/FFE66D/000000?text=Samsung+S23',
      'brand': 'Samsung',
      'rating': 4.5,
      'reviewCount': 89,
      'category': 'Электроника',
    },
    {
      'id': '6',
      'title': 'Converse Chuck Taylor',
      'price': 5990,
      'oldPrice': 7990,
      'discount': 25,
      'imageUrl': 'https://via.placeholder.com/400x400/FF6B9D/FFFFFF?text=Converse+Chuck',
      'brand': 'Converse',
      'rating': 4.4,
      'reviewCount': 312,
      'category': 'Обувь',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((product) {
      // Фильтр по поисковому запросу
      final matchesSearch = _searchQuery.isEmpty ||
          product['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product['brand'].toLowerCase().contains(_searchQuery.toLowerCase());

      // Фильтр по категории
      final matchesCategory = _selectedCategory == 'Все' ||
          product['category'] == _selectedCategory;

      // Фильтр по цене
      final matchesPrice = product['price'] >= _minPrice && product['price'] <= _maxPrice;

      return matchesSearch && matchesCategory && matchesPrice;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // App Bar с поиском
          _buildSearchAppBar(),
          
          // Фильтры
          if (_showFilters) _buildFiltersSection(),
          
          // Результаты поиска
          Expanded(
            child: _searchQuery.isEmpty && _selectedCategory == 'Все' && !_showFilters
                ? _buildSearchSuggestions()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Кнопка назад
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Поле поиска
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Поиск товаров...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _searchFocusNode.unfocus();
                          },
                          icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Кнопка фильтров
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showFilters 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune,
                color: _showFilters 
                    ? Colors.white 
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Категории
          Text(
            'Категория',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Сортировка
          Text(
            'Сортировка',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedSort,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _sortOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSort = value!;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Диапазон цен
          Text(
            'Диапазон цен',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: '0',
                  decoration: InputDecoration(
                    labelText: 'От',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _minPrice = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: '100000',
                  decoration: InputDecoration(
                    labelText: 'До',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _maxPrice = double.tryParse(value) ?? 100000;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Кнопка сброса фильтров
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'Все';
                  _selectedSort = 'Популярные';
                  _minPrice = 0;
                  _maxPrice = 100000;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Сбросить фильтры'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Популярные поиски
          Text(
            'Популярные поиски',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'Nike', 'Adidas', 'Levi\'s', 'Apple', 'Samsung', 'Кроссовки',
              'Джинсы', 'Часы', 'Телефон', 'Спорт', 'Мода', 'Стиль'
            ].map((tag) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = tag;
                    _searchController.text = tag;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 40),
          
          // Категории
          Text(
            'Популярные категории',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildCategoryCard('Обувь', Icons.sports_soccer, Colors.blue),
              _buildCategoryCard('Одежда', Icons.checkroom, Colors.green),
              _buildCategoryCard('Электроника', Icons.phone_android, Colors.purple),
              _buildCategoryCard('Спорт', Icons.fitness_center, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
          _showFilters = true;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final products = _filteredProducts;
    
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Товары не найдены',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Попробуйте изменить параметры поиска\nили фильтры',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Заголовок с количеством результатов
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                'Найдено ${products.length} товаров',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Сортировка: $_selectedSort',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Сетка товаров
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                id: product['id'],
                title: product['title'],
                price: product['price'],
                oldPrice: product['oldPrice'],
                discount: product['discount'],
                imageUrl: product['imageUrl'],
                brand: product['brand'],
                rating: product['rating'],
                reviewCount: product['reviewCount'],
              );
            },
          ),
        ),
      ],
    );
  }
}
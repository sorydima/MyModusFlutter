import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../provider/product_provider.dart';
import '../widgets/product_card.dart';

class WildberriesStoreScreen extends StatefulWidget {
  const WildberriesStoreScreen({Key? key}) : super(key: key);

  @override
  State<WildberriesStoreScreen> createState() => _WildberriesStoreScreenState();
}

class _WildberriesStoreScreenState extends State<WildberriesStoreScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _onCategoryChanged(String category, ProductProvider productProvider) {
    productProvider.filterByCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Modus - Wildberries"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: productProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = productProvider.categories.entries.elementAt(index);
                    final isSelected = productProvider.selectedCategory == category.key;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.value),
                        selected: isSelected,
                        onSelected: (_) => _onCategoryChanged(category.key, productProvider),
                        selectedColor: Colors.purple.shade100,
                        checkmarkColor: Colors.purple,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          
          // Products grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.purple),
                        SizedBox(height: 16),
                        Text("Загружаем товары My Modus..."),
                      ],
                    ),
                  );
                }

                if (productProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text("Ошибка загрузки: ${productProvider.error}"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            productProvider.clearError();
                            productProvider.retryFetchProducts();
                          },
                          child: const Text("Попробовать снова"),
                        ),
                      ],
                    ),
                  );
                }

                if (productProvider.filteredProducts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Товары не найдены"),
                        SizedBox(height: 8),
                        Text("Попробуйте выбрать другую категорию"),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: productProvider.filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: productProvider.filteredProducts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

} 